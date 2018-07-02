# The Ingest Pipeline

Clients that send data to Humio are configured with an ingest token and when data
arrives at Humio this token determines which repository the events are stored in
and how the message is processed by the repository's _ingest pipeline_.

An ingest pipeline is a script written in Humio's Pipeline Language; It can
extract new fields, assign tags, and route events to other pipelines for further
processing or to be stored in another repository.

## Inputs

Each ingest pipeline has one or more _inputs_. An input is way for data to enter
Humio. If data is sent to Humio using [Rsyslog]({{< ref "rsyslog.md" >}}) for instance, you would configure
a _Socket Listeners_ with a specific network port, data sent to that socket would
then arrive as input data that input's pipeline script. If you use FileBeat,
you would create an "ElasticSearch Bulk Input" and events sent to Humio's
ElasticSearch API with the Ingest Token of the input, would enter the pipeline through
the pipeline script of the ElasticSearch Bulk Input. The available inputs are:

- Socket Listeners
- ElasticSearch Bulk API
- Humio Message API
- Humio Ingest API
- Upstream Input

Each repository has its own set of inputs and scripts. Each of them define an
endpoint for data to enter Humio from an external source, with one exception,
_Upstream Inputs_, which are [described in the routing section]({{< ref "#routing" >}}).

## Pipeline Scripts

Each input has an associated pipeline script. By default, it does nothing and
simply stores the event directly to the repository's data store. Since the
pipeline known nothing about the format or fields available in the incoming data.

Humio offers a plethora of functions for parsing incoming events. Usually a pipeline
script will look something like this:

```humio
@timestamp := parseTimestamp() |
parseKeyValues() |
case {
  loglevel = /error/i | errorMessage := $parseErrorMessage(); // Calls a custom parser function.
  *; // Default Case: Don't do anything
}
```

This example pipeline script uses the {% function "parseTimestamp" %} that automatically
tries to determine the timestamp of the input by applying a series of regular expressions.
It then extracts all key value pairs (of form `key=value`) form the event as new fields
using the {% function "parseKeyValues" %} function. Finally it uses a [`case`]({{< ref "language-syntax/_index.md#case" >}})
statement to conditionally extract a field `errorMessage` using a user function called
"parseErrorMessage".

## Dropping Events

It is perfectly fine to drop events as part of the ingest pipeline. Depending on
your use-case, e.g. there might data that is sensitive or simply garbage and you just want
to get rid of it. For this you can either use a filter expression that excludes
some events, e.g.:

```humio
parseKeyValues() | location.region != "europe"
```

This pipeline discards all events that `location.region` is not `"europe"`.
Alternatively you can use the {{% function "drop" %}} which will not match
any events - this is especially useful when used together with case-statements, e.g.:

```humio
parseKeyValues() |
case {
  loglevel=INFO | ...;
  loglevel=TRACE | drop();
  loglevel=ERROR | ...;
  loglevel=* | error("Unknown value for loglevel. value=%s", values=[loglevel]);
  * |; // Default case: no loglevel field present - ignore.
}
```

In this example, for some reason we are not interested in storing the logs with the
`TRACE` level and use the {{% function "drop" %}} function to discard them.

## User Functions

Pipeline scripts can quickly grow large and become hard to read. You can split up
your pipeline script by defining user functions. User functions in the ingest pipeline
work exactly like [user functions in search queries]({{< ref "language-syntax/_index.md#user-functions" >}}).

...

## Grok Patterns

You can also add Grok files as part of your ingest pipeline. Each file defines
a set of Grok patterns that can be used in the {{% function "grok" %}} function.
This gives you a more compossible alternative [regular expression field extraction]({{< "language-syntax/_index.md#extracting-fields" >}}).

Any grok patterns defined in the ingest pipeline can also be used in the search view.

## Routing {#routing}

In most cases you will want store events in the repository the ingest pipeline is
defined on. But sometimes in more complex set-ups like a shared Kubernetes cluster
or when you want different retention rules for different types of data, you can
route (or forward) events to other pipelines, this is called routing.

Routing is done using the {{% function "forward" %}} function. When used in a pipeline
the events it is applied to is forwarded at the end.

### Example: Routing Pipeline with Dead Letters

```humio
parseKeyValues() |
case {
  hostname=nginx* | forward("nginx");
  service.name=* | forward(`service.name`); // TODO: Discuss how to dereference a field.
  * | error("No field 'service.name' or missing downstream repo.") | forward("deadLetters");
}
```
In the first clause of the case statement matches all event that have a field `hostname` with a value
starts with `nginx` (e.g. `nginx-01`, `nginx.dev`) should all be forwarded to the upstream repository `nginx`.

The second clause `service.name=*` matches anything that has a value for `service.name`, it then forwards
the event based on the value of `service.name`.
What is neat about the {{% function "forward" %}} function is that is only matches an event if there
is an downstream repository with a matching name.

This means that if we e.g. have a downstream repository called `webapp` and
we called {{< query >}}forward("webapp"){{< /query >}} the expression would match. If on the other
hand we did not have a downstream repository called `webapp` the event would fall through to the
next line in the case statement. In the case above we have made a catch all clause in the case-statement
that forwards any non-matching events to a downstream repository we have called `deadLetters` (it could be called anything).
This can be a nifty trick as it lets you inspect the events that don't match without just dropping the event entirely.

### Default Repository

If an event is not forwarded to a downstream repository the event is stored in
the current one.

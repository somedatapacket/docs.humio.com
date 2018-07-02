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
- Forward Input

Each repository has its own set of inputs and scripts. Each of them define an
endpoint for data to enter Humio from an external source, with one exception,
_Forward Inputs_, which are [described below]({{< ref "#forward" >}}).

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

## User Functions

Pipeline scripts can quickly grow large and become hard to read. You can split up
your pipeline script by defining user functions. User functions in the ingest pipeline
work exactly like [user functions in search queries]({{< ref "language-syntax/_index.md#user-functions" >}}).  

## Grok Patterns

## Event Forwarding {#forward}

### Default Repository

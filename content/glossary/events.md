---
title: Events
aliases: ["/concepts/events"]
---

The data stored in Humio are called events. An event is a piece of data and an
associated timestamp.

Examples of events include:

- Log Lines
- Metric Data
- Analytics Data

but ANY piece of data with an associated timestamp can be thought of as an event.

**Example**  
When data is sent to Humio - in this example a log line - the associated parser
converts the data into an event. If Humio received:

```
[2018-10-11 22:00:10] INFO - User Logged In. userId=97110
```

This might be turned into an event data containing the following fields:

| Field      | Value                                                     |
|------------|-----------------------------------------------------------|
| @rawstring | [2018-10-11 22:00:10] INFO - User Logged In. userId=97110 |
| @id        | 3gqidgqi_uwgdwqu121duqgdw2iqwud_721gqwdugqdwu1            |
| @timestamp | 2018-10-11 22:00:10                                       |
| @timezone  | Z                                                         |
| #repo      | server-logs                                               |
| #type      | my-parser                                                 |
| loglevel   | INFO                                                      |
| message    | User Logged In.                                           |
| userId     | 97110                                                     |

## Field Types

There are three types of fields:

- [metadata fields]({{< ref "#metadata" >}})
- [tag fields]({{< ref "#tags" >}})
- [user fields]({{< ref "#user-fields" >}})

### Metadata Fields {#metadata}

Each event has some metadata attached to it on ingestion, e.g. all events will
have an `@id`, `@timestamp`, `@timezone`, `@display` and `@rawstring` field.

Notice that metadata fields start with all `@` to make them easy to identity.

The three most important are `@timestamp`, `@rawstring`, and `@display` and will be
described in detail below.

### Tag Fields {#tags}

[Tags]({{< ref "tagging.md" >}}) fields define how events are physically stored and 
indexed. They are also used for speeding up queries.

Users can associate custom tags as part of the parsing and ingestion process but 
their use is usually very limited. The only built-in tags are `#repo` and `#type` and 
both are described in detail below.

Usually the client sending data to Humio will be configured to include `#host`
and `#source` tags that contain the hostname and file that the event was read from.

### User Fields {#user-fields}

Any field that is not a tag or metadata is a user field. They are extracted at
ingest by a parser or [at query time by a regular expression]({{< ref "language-syntax/_index.md#extracting-fields" >}}).
User fields are usually the interesting part of an event, containing application
specific information.

### Field: @rawstring {#rawstring}

Humio represents the original text of the event in the `@rawstring` attribute.

One of the greatest strengths of Humio is that it keeps the original data and
nothing is thrown away at ingest. This allows you to do free-text searching across
all logs and to extract virtual fields at query time for parts of the
data you did not even know would be important.

You can read more about [free-text search]({{< ref "language-syntax/_index.md#grepping" >}}) and 
[extracting fields]({{< ref "language-syntax/_index.md#extracting-fields" >}}) in
the search documentation.

### Field: @timestamp {#timestamp}

The timestamp of an event is represented in the `@timestamp` field. This field
defines where the event is stored in Humio's database and is what defines
wether an event is included in search results when searching a time range.

The timestamp needs [special treatment when parsing incoming data]({{< ref "creating-a-parser.md#parsing-timestamps">}}) during ingestion.

### Field: @display {#display}

By default Humio will display the content of the `@rawstring` field in the
Event List. Sometimes this is not what you want, e.g the message could be very
long and the relevant information be at the end of `@rawstring`, or you might
want to be able to see a single field contained in the message.

You can fix this by assigning a value to the `@display` field.
For example you might only want to see the `method` and `url` fields from your event data. 
To achieve this you can use Humio's [format]({{< ref "query-functions/_index.md#format">}}) function
combined with the `@display` field to achieve this.

The following query extracts the `method` and `url` fields from the event data and sets 
the `@display` field using the `format` function:

``` humio
@display := format("%s %s", field=[method, url])
```

and outputs the results as demonstrated in the example below:

```
GET /path/to/page
POST /path/to/other/page
```

As you can see Humio uses a printf-like syntx to format the resulting message.

### Field: #repo {#repo}

All events have a special `#repo` tag that denotes the [repository]({{< ref "repositories.md" >}}) that 
the event is stored in. This is useful in cross-repository searches when using [views]({{< ref "views.md" >}}).

### Field #type {#type}

The type field is the name of the [parser]({{< ref "parsers/_index.md" >}}) used to ingest the data.

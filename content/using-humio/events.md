---
title: Events
---

The data stored in Humio is called events. An event is a piece of data and an
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

Each even has some metadata attached to it on ingestion, e.g. all events will
have an `@id`, `@timestamp`, `@timezone`, and `@rawstring` field.

Notice that metadata fields start with all `@` to make them easy to identity.

The two most important are `@timestamp` and `@rawstring`, and will both be
described in detail below.

### Tag Fields {#tags}

[Tags]({{< ref "tags.md" >}}) fields that define how events are physical stored and indexed. They are
used for speeding up queries.

Users can associate custom tags as part of the parsing and ingestion process.
But their use is usually very limited. The only built-in tags are `#repo`, `#type`,
both are described in detail below.

Usually the client sending data to Humio will be configured to include `#host`
and `#source` tags, containing the hostname and file the event was read from.

### User Fields {#user-fields}

Any field that is not a tag or metadata is a user field. They are extracted at
ingest by a parser or [at query time by a regular expression]({{< ref "searching/_index.md#extracting-fields" >}}).
User fields are usually the interesting part of an event, containing application
specific information.

### Field: @rawstring {#rawstring}

Humio represents the original text of the event in the attribute `@rawstring`.

One of the greatest strengths of Humio is that the original data is kept and
nothing is thrown away at ingest. This allows you to do free-text searching across
all logs, and to extract virtual fields at query time - fields for parts of the
data you did not even know would be important.

You can read more [free-text search]({{< ref "searching/_index.md#grepping" >}}) and
about [extracting fields]({{< ref "searching/_index.md#extracting-fields" >}}) in
the search documentation.

### Field: @timestamp {#timestamp}

The timestamp of an event is represented in the `@timestamp` attribute.

### Field: #repo {#repo}

All event have a special `#repo` tag that denotes the [repository]({{< ref "repositories.md" >}}) the event is stored in.
This is useful in cross-repository searches when using [views]({{< ref "views.md" >}}).

### Field #type {#type}

The type field is the name of the [parser]({{< ref "parsing.md" >}}) used to ingest the data.

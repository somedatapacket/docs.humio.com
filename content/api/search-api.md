---
title: Search API
weight: 200
---



## Query

This is the main endpoint for executing queries in Humio.

This endpoint streams results as soon as they are calculated, but depending on
the query type ([filter](/glossary#filter-queries) or
[aggregate](/glossary#aggregate-queries)), the time of delivery changes.  The following table illustrates this:

|                | Live query                                   | Standard query                                   |
|:--------------:|:--------------------------------------------:|:------------------------------------------------:|
| **Filter**     | Streaming                                    | Streaming                                        |
| **Aggregate**  | Error (use [query jobs](#query-jobs-create)) | "Streaming" (but result will only come at the end) |

The endpoint streams results for **filter queries** as they happen.

For **aggregate standard queries**, the
result is not ready until the query has processed all events in the
query interval. The request is blocked until the result is ready. It is at this point that Humio sends the result back.

For **aggregate live queries**, this endpoint returns an error. What
you want in this situation is to get a snapshot of the complete result
set at certain points in time (fx every second), but the query end
point does not support this behavior. Instead, you should use the [query
job endpoint](#query-jobs-create) and then poll the result when you need it.



<!-- This query API is designed for integrations. It is possible to
stream large amounts of data out of Humio or to make a blocking query
waiting for the final result.  How the data is returned depends on the
query. If an [aggregate function](/glossary/#aggregate-queries) is used,
the server cannot return the result until the query has finished.  It
is possible to use the [polling query
endpoint](http-api.md#poll-based-query.md) to continuously poll for
partial results. This is what the Humio UI does.  If the query is not
using aggregate functions, like filter queries, the result can be
streamed as events are found.  [Live
queries](/glossary/#live-queries) are continuous queries that newer
ends. A live query that aggregates data is not suited for this
endpoint. Use the [polling query
endpoint](http-api.md#poll-based-query.md).  This is illustrated in
the table below.  -->


### Request

To start a query, POST the query to:

```
POST /api/v1/repositories/$REPOSITORY_NAME/query
```

The JSON request body has the following attributes:

Name        | Type   | Required     | Description
----------- | ------ | ------------ | -------------
`queryString` | string |  Yes         | The actual query. See [Query language]({{< ref "/language-syntax/_index.md" >}}) for details
`start`       | Time   |  No          | The start date and time. This parameter tells Humio not to return results from before this date and time. You can learn how to [specify a time](#time).
`end`         | Time   |  No          | The end date and time.  This parameter tells Humio not to return results from after this date and time. You can learn how to [specify a time](#time)
`isLive`      | boolean|  No         | Sets whether this query is live. Defaults to `false`. Live queries are continuously updated.
`timeZoneOffsetMinutes`      | number|  No   | Set the time zone offset used for `bucket()` and `timechart()` time slices, which is significant if the corresponding `span` is multiples of days.  Defaults to `0` (UTC); positive numbers are to the east of UTC, so for `UTC+01:00` timezone the value `60` should be passed.
`arguments`   | object|  No   | Dictionary of arguments specified in queries with `?param` or `?{param=defaultValue}` syntax.  Provided arguments must be a simple dictionary of string values. If an argument is given explicitly as in `?query(param=value)` then that value overrides values provided here.

If you use this API from a browser application, you may want to trigger "direct download".
You can achieve this by adding the HTTP header "X-Desired-Filename" to the request.
That will result in the response having the header "Content-Disposition" with the value
"attachment; filename=\"DESIRED_FILE_NAME\".

### Time
There are two ways of specifying the `start` and `end` time for a query:

#### Absolute time

With absolute time, you specify a number that expresses the precise time in milliseconds since the Unix epoch (Unix time) in the UTC/Zulu time zone. This method is shown in the following example:

``` json
{
  "queryString": "",
  "start": 1473449370018,
  "end": 1473535816755
}
```

#### Relative time

With relative time, you specify the start and end time as a relative time
such as `1minute` or `24 hours`.
Humio supports this using _relative time modifiers_. Humio treats the start and
end times as relative times if you specify them as strings.

When providing a timestamp, relative time modifiers are specified relative to "now".

See the relative time syntax [here]({{< ref "relative-time-syntax.md" >}})

{{% notice note %}}
Relative time modifiers are always relative to now.
{{% /notice %}}

This method is shown in the following examples:

Search the last 24 hours:
``` json
{
  "queryString": "ERROR",
  "start": "24hours",
  "end": "now"
}
```

You can also mix relative and absolute time modifiers. For example, to search from a specified moment in time until two days ago:
``` json
{
  "queryString": "loglevel=ERROR",
  "start": 1473449370018,
  "end": "2days"
}
```

{{% notice note %}}
***Omitted and required arguments***

Humio has defined behavior when you omit time arguments:

* If you omit the`end` argument, it gets the default value `now`.  
* If you omit the `start` argument, it gets the default value of `24hours`.  

For [*_live queries_*](/glossary/#live-queries), you must either set `end` to "now", or omit it. You must set `start` to a relative time modifier.
{{% /notice %}}

### Response

Humio returns data in different formats depending on the media type you set in the [`ACCEPT`](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html)
header of the HTTP request.

Data can be returned in the following formats:

| Media type | Description |
------------|-------------|
| `text/plain` (default)   |   Returns events delimited by newlines. <br /><br />If the event has a `rawstring` field, then Humio prints it as the event. If it does not, then Humio prints all fields on the event in the format `a->hello, b->world`. <br /> Note that the event can contain newlines. Nothing is escaped.
| `application/json`   |   Returns events in a standard JSON array. <br /><br />All field values in each event are returned as JSON strings, except for `@timestamp`. The `@timestamp` field is returned a long integer, representing time as Unix time in milliseconds (UTC/Zulu time). <br> Newlines inside the JSON data are escaped as `\n`
| [`application/x-ndjson`](http://specs.frictionlessdata.io/ndjson/)   | Returns events as [Newline Delimited JSON (NDJSON)](http://specs.frictionlessdata.io/ndjson/). <br /><br />This format supports streaming JSON data. Data is returned with one event per line. <br /><br /> Newlines inside the JSON data are escaped as `\n`.


### Example

#### Live query streaming all events

This live query returns an empty search, finding all events in a time window going 10 seconds back in time.

Notice the `ACCEPT` header. This tells the server to stream data as [Newline Delimited JSON](http://specs.frictionlessdata.io/ndjson/).

```shell
curl https://cloud.humio.com/api/v1/repositories/$REPOSITORY_NAME/query \
  -X POST \
  -H "Authorization: Bearer $API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H "Accept: application/x-ndjson" \
  -d '{"queryString":"","start":"10s","isLive":true}'
```


#### Aggregate query returning standard JSON

This query groups results by service and counts the number of events for each service. The query blocks until it is complete and returns events as a JSON array:

``` shell
curl https://cloud.humio.com/api/v1/repositories/$REPOSITORY_NAME/query \
  -X POST \
  -H "Authorization: Bearer $API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H "Accept: application/json" \
  -d '{"queryString":"count()","start": "1h","end":"now","isLive":false}'
```


### Query Jobs

#### Create

The Query Jobs endpoint lets you run a query and check its status later.

To execute a query using the Query Jobs endpoint, you first have to
start it, and then subsequently poll its current status in a separate
request.

The Query Jobs endpoint is designed to support the web front end.
This means that filter queries only return a maximum of 200 matching events
and aggregate queries up to a maximum of 1500 rows.  The API has
facilities to support user interfaces (see the [response](#response_2)
of the Query Jobs poll endpoint).

#### Request

To start a Query Job, POST the query to:

```
POST /api/v1/repositories/$REPOSITORY_NAME/queryjobs
```

The request body is similar to the [request body](#request) in the query endpoint.


#### Response

Starting a query yields a response of the form:

```json
HTTP/1.1 200 OK
{ id: "some-long-id" }
```

The `id` field indicates the `$ID` for the query, which you can then poll
using the HTTP GET method (see [below](#poll)).

#### Example

``` shell
curl https://cloud.humio.com/api/v1/repositories/$REPOSITORY_NAME/queryjobs \
 -X POST \
 -H 'Authorization: Bearer $API_TOKEN' \
 -H 'Content-Type: application/json' \
 -H 'Accept: application/json' \
 -H 'Accept-Encoding: ' \
 -d '{"queryString":"","start": "1d","showQueryEventDistribution":true,"isLive":false}'
```


### Poll

This endpoint lets you poll running Query Jobs.

### Request

To poll a running Query Job, make an HTTP GET request to the job.

In the following example request, replace `$ID` with the ID from the response of the [Query Job create request](#create):

```
GET     /api/v1/repositories/$REPOSITORY_NAME/queryjobs/$ID
```

#### Response

When Humio runs a search, it returns partial results. It returns the results that it found
at the time of the polling.  Humio searches the newest data
first, and then searches progressively backward in time.

This way, Humio produces some results right away. The `done: true` property in a poll query
shows if the query is finished.

The response is a JSON object with the following attributes:

Name                   |   Type        |  Description
-----------------------|---------------|--------------
`done`                   | boolean       | True if the query has run to completion.
`events`                 | Array[Event]  | The 200 most recent elements of the query response.
`metaData`               | QueryMetaData | Information about the query.
`queryEventDistribution` | EventDistData | Information used to render the distribution graph. Only present in the response if `showQueryEventDistribution` was set to true.

The `MetaData` field contains the number of matching events, the query
boundary, and information about the attributes and their unique value
domains in the response.


{{% notice warning %}}
***Query timeouts***

If you do not poll a query for 30 seconds, then it stops and deletes itself.

Live queries keep running for an hour without being polled.
{{% /notice %}}

#### Example

```shell
curl https://cloud.humio.com/api/v1/repositories/$REPOSITORY_NAME/queryjobs/$ID \
  -H "Authorization: Bearer $API_TOKEN"
```

### Delete

Stops running Query Jobs.

#### Request

To stop a Query Job, you can issue a `DELETE` request to the URL of the Query Job:

```
DELETE     /api/v1/repositories/$REPOSITORY_NAME/queryjobs/$ID
```

#### Response

Standard HTTP response codes.

#### Example

```shell
curl https://cloud.humio.com/api/v1/repositories/$REPOSITORY_NAME/queryjobs/$ID \
 -X DELETE \
 -H "Authorization: Bearer $API_TOKEN"
```

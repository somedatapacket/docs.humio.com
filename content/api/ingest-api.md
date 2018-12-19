---
title: "Ingest API"
weight: 300
---

There are different ways of getting data into Humio.
This page show how to send data using the HTTP API.

There are 2 endpoints. [One for sending data that needs to be parsed using a specified parser.](#parser)
And another [endpoint for sending data that is already structured.](#structured-data)
When parsing text logs like syslogs, accesslogs or logs from applications you
typically use the endpoint where a parser is specified.


### Ingest unstructured data using a parser {#parser}

This endpoint should be used when you have unstructured logs. E.g. some text format and you want to give those
logs structure to enable easier searching in Humio.
You can either use a built-in parser or create a custom [parser]({{< ref "parsers/_index.md" >}}).

{{% notice note %}}
***Filebeat is another option for sending data that needs a parser***

Another option is to use [Filebeat]({{< relref "filebeat.md" >}}).
Filebeat is a lightweight open source agent that can monitor files and ship
data to Humio. When using filebeat it is also possible to specify a parser for the data.
Filebeat can handle many problems like network problems, retrying, batching, spikes in data etc.
{{% /notice %}}

```
POST	/api/v1/ingest/humio-unstructured
```

Example sending 4 accesslog lines to Humio

``` json
[
  {
    "fields": {
      "host": "webhost1"
    },
    "messages": [
       "192.168.1.21 - user1 [02/Nov/2017:13:48:26 +0000] \"POST /humio/api/v1`/dataspaces/humio/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 664 0.015",
       "192.168.1.49 - user1 [02/Nov/2017:13:48:33 +0000] \"POST /humio/api/v1/dataspaces/developer/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.014 657 0.014",
       "192.168.1..21 - user2 [02/Nov/2017:13:49:09 +0000] \"POST /humio/api/v1/dataspaces/humio HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.013 565 0.013",
       "192.168.1.54 - user1 [02/Nov/2017:13:49:10 +0000] \"POST /humio/api/v1/dataspaces/humio/queryjobs HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 650 0.015"
    ]`
  }
]
```

The above example sends 4 accesslog lines to Humio. In this case we have attached an `accesslog` parser to the [ingest token]({{< relref "sending-data-to-humio/ingest-tokens.md" >}}) we are using. See [parsing]({{< relref "parsers/_index.md" >}}) for details.
The `fields` section is used to specify fields that should be added to each of the events when they are parsed. In the example all the accesslog events will get a host field telling the events came from `webhost1`.
It is possible to send events of different types in the same request. That is done by adding a new element to the outer array in the example above.
Tags can be specified through the parser.

#### Events {#events}

When sending events, you can set the following standard fields:

Name            | Required      | Description
------------    | ------------- |------------
`messages`      | yes           | The raw strings representing the events. Each string will be parsed by the parser.
`type`          | no            | If no [parser]({{< relref "parsers/_index.md" >}}) is attached to the ingest token Humio will use this parser.
`fields`        | no            | Annotate each of the `messages` with these key-values. Values must be strings.
`tags`          | no            | Annotate each of the `messages` with these key-values as Tags. Please see other documentation on tags before using.

#### Examples

Previous example as a curl command:

``` shell
curl -v -X POST localhost:8080/api/v1/ingest/humio-unstructured \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $INGEST_TOKEN" \
-d @- << EOF
[
  {
    "fields": {
      "host": "webhost1"
    },
    "messages": [
       "192.168.1.21 - user1 [02/Nov/2017:13:48:26 +0000] \"POST /humio/api/v1/dataspaces/humio/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 664 0.015",
       "192.168.1.49 - user1 [02/Nov/2017:13:48:33 +0000] \"POST /humio/api/v1/dataspaces/developer/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.014 657 0.014",
       "192.168.1.21 - user2 [02/Nov/2017:13:49:09 +0000] \"POST /humio/api/v1/dataspaces/humio HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.013 565 0.013",
       "192.168.1.54 - user1 [02/Nov/2017:13:49:10 +0000] \"POST /humio/api/v1/dataspaces/humio/queryjobs HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 650 0.015"
    ]
  }
]
EOF
```


### Ingest structured data {#structured-data}
This API should be used when data is already structured. An extra parsing step is possible by attaching a parser to the used ingest-token.

```
POST	/api/v1/ingest/humio-structured
```

The following example request contains two events. Both these events share the same tags:

``` json
[
  {
    "tags": {
      "host": "server1",
      "source": "application.log"
    },
    "events": [
      {
        "timestamp": "2016-06-06T12:00:00+02:00",
        "attributes": {
          "key1": "value1",
          "key2": "value2"
        }
      },
      {
        "timestamp": "2016-06-06T12:00:01+02:00",
        "attributes": {
          "key1": "value1"
        }
      }
    ]
  }
]
```


You can also batch events with different tags into the same request as shown in the following example.

This request contains three events. The first two are tagged with `server1` and the third is tagged with `server2`:

``` json
[
  {
    "tags": {
      "host": "server1",
      "source": "application.log"
    },
    "events": [
      {
        "timestamp": "2016-06-06T13:00:00+02:00",
        "attributes": {
          "hello": "world"
        }
      },
      {
        "timestamp": "2016-06-06T13:00:01+02:00",
        "attributes": {
          "statuscode": "200",
          "url": "/index.html"
        }
      }
    ]
  },
  {
    "tags": {
      "host": "server2",
      "source": "application.log"
    },
    "events": [
      {
        "timestamp": "2016-06-06T13:00:02+02:00",
        "attributes": {
          "key1": "value1"
        }
      }
    ]
  }
]
```


#### Tags

Tags are key-value pairs.

Events are stored in data sources. A repository has a set of Data Sources.
Data sources are defined by their tags. An event is stored in a data source
matching its tags. If no data source with the exact tags exists it is created.
Tags are used to optimize searches by filtering out unwanted events.
At least one tag must be specified.
See the [tags documentation]({{< ref "tagging.md" >}}) for more information.

#### Events

When sending an Event, you can set the following standard fields:

Name            | Required      | Description
------------    | ------------- |-----
`timestamp`     | yes           | You can specify the `timestamp` in two formats. <br /> <br /> You can specify a number that sets the time in millisseconds (Unix time). The number must be in Zulu time, not local time. <br /><br />Alternatively, you can set the timestamp as an ISO 8601 formatted string, for example, `yyyy-MM-dd'T'HH:mm:ss.SSSZ`.
`timezone`      | no            | The `timezone` is only required if you specify the `timestamp` in milliseconds. The timezone specifies the local timezone for the event. Note that you must still specify the `timestamp` in Zulu time.
`attributes`    | no            | A JSON object representing key-value pairs for the Event. <br /><br />These key-value pairs adds structure to Events, making it easier to search. Attributes can be nested JSON objects, however, we recommend limiting the amount of nesting.
`rawstring`     | no            | The raw string representing the Event. The default display for an Event in Humio is the `rawstring`. If you do not provide the `rawstring` field, then the response defaults to a JSON representation of the `attributes` field.

#### Event examples

``` json
{
    "timestamp": "2016-06-06T12:00:00+02:00",
    "attributes": {
        "key1": "value1",
        "key2": "value2"
    }
}
```

``` json
{
    "timestamp": 1466105321,
    "attributes": {
        "service": "coordinator"
    },
    "rawstring": "starting service coordinator"
}
```

``` json
{
    "timestamp": 1466105321,
    "timezone": "Europe/Copenhagen",
    "attributes": {
        "service": "coordinator"
    },
    "rawstring": "starting service coordinator"
}
```

``` json
{
    "timestamp": "2016-06-06T12:00:01+02:00",
    "rawstring": "starting service=coordinator transactionid=42"
}
```

#### Response

Standard HTTP response codes.

#### Example

``` shell
curl $BASEURL/api/v1/ingest/humio-structured \
 -X POST \
 -H "Content-Type: application/json" \
 -H "Authorization: Bearer $INGEST_TOKEN" \
 -d '[{"tags": {"host":"myserver"}, "events" : [{"timestamp": "2016-06-06T12:00:00+02:00", "attributes": {"key1":"value1"}}]}]'
```

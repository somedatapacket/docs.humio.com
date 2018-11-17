---
title: "Ingest API"
weight: 300
---

There are different ways of getting data into Humio.
This page show how to send data using the HTTP API.

There are 2 endpoints. [One for sending data that will be parsed using a specified parser.](#parser)
And another [endpoint for sending data that is already structured and does not need parsing.](#structured-data)  
When parsing text logs like syslogs, accesslogs or logs from applications you
typically use the endpoint where a parser is specified.


### Ingest data using a parser {#parser}

This API should be used, when a parser should be applied to the data.
It is possible to create [parsers]({{< ref "parsers/_index.md" >}}) in Humio

{{% notice note %}}
***Filebeat is another option for sending data that needs a parser***

Another option, that is related to this API is to use [Filebeat]({{< relref "filebeat.md" >}}).  
Filebeat is a lightweight open source agent that can monitor files and ship
data to Humio. When using filebeat it is also possible to specify a parser for the data.
Filebeat can handle many problems like network problems, retrying, batching, spikes in data etc.
{{% /notice %}}

```
POST	/api/v1/dataspaces/$REPOSITORY_NAME/ingest-messages
```

Example sending 4 accesslog lines to Humio

``` json
[
  {
    "type": "accesslog",
    "fields": {
      "host": "webhost1"
    },
    "messages": [
       "192.168.1.21 - user1 [02/Nov/2017:13:48:26 +0000] \"POST /humio/api/v1/dataspaces/humio/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 664 0.015",
       "192.168.1.49 - user1 [02/Nov/2017:13:48:33 +0000] \"POST /humio/api/v1/dataspaces/developer/ingest HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.014 657 0.014",
       "192.168.1..21 - user2 [02/Nov/2017:13:49:09 +0000] \"POST /humio/api/v1/dataspaces/humio HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.013 565 0.013",
       "192.168.1.54 - user1 [02/Nov/2017:13:49:10 +0000] \"POST /humio/api/v1/dataspaces/humio/queryjobs HTTP/1.1\" 200 0 \"-\" \"useragent\" 0.015 650 0.015"
    ]
  }
]
```

The above example sends 4 accesslog lines to Humio. the parser is specified using the `type` field and is set to `accesslog`.   
The parser accesslog should be specified in the repository. See [parsing]({{< relref "parsers/_index.md" >}}) for details.  
The `fields` section is used to specify fields that should be added to each of the events when they are parsed. In the example all the accesslog events will get a host field telling the events came from webhost1.  
It is possible to send events of different types in the same request. That is done by adding a new element to the outer array in the example above.
Tags can be specified in the parser pointed to by the `type` field

#### Events {#events}

When sending events, you can set the following standard fields:

Name            | Required      | Description
------------    | ------------- |------------
`messages`      | yes           | The raw strings representing the events. Each string will be parsed by the parser specified by `type`.
`type`          | yes           | The [parser]({{< relref "parsers/_index.md" >}}) Humio will use to parse the `messages`
`fields`        | no            | Annotate each of the `messages` with these key-values. Values must be strings.
`tags`          | no            | Annotate each of the `messages` with these key-values as Tags. Please see other documentation on tags before using.

#### Examples

Previous example as a curl command:

``` shell
curl -v -X POST localhost:8080/api/v1/dataspaces/developer/ingest-messages/ \
-H "Content-Type: application/json" \
-d @- << EOF
[
  {
    "type": "accesslog",
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

Shorter example using the built-in kv parser

``` shell
curl -v -X POST localhost:8080/api/v1/dataspaces/developer/ingest-messages/ \
-H "Content-Type: application/json" \
-d @- << EOF
[
  {
    "type": "kv",
    "messages": [
       "2018-01-01T12:00:00+02:00 a=1 b=2"
    ]
  }
]
EOF
```

### Ingest structured data {#structured-data}
This API should be used when data is well structured and no extra parsing
is needed. (Except for the optional extra key-value parsing)

```
POST	/api/v1/dataspaces/$REPOSITORY_NAME/ingest
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


You can also batch events with different tags into the same request, as shown in the following example.

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
Tags are used as query boundaries when searching
Tags are provided as a JSON object containing key-value pairs. Keys and values
must be strings, and at least one tag must be specified.
See the [tags documentation]({{< ref "tagging.md" >}}) for more information.

#### Events

When sending an Event, you can set the following standard fields:

Name            | Required      | Description
------------    | ------------- |-----
`timestamp`     | yes           | You can specify the `timestamp` in two formats. <br /> <br /> You can specify a number that sets the time in millisseconds (Unix time). The number must be in Zulu time, not local time. <br /><br />Alternatively, you can set the timestamp as an ISO 8601 formatted string, for example, `yyyy-MM-dd'T'HH:mm:ss.SSSZ`.
`timezone`      | no            | The `timezone` is only required if you specify the `timestamp` in milliseconds. The timezone specifies the local timezone for the event. Note that you must still specify the `timestamp` in Zulu time.
`attributes`    | no            | A JSON object representing key-value pairs for the Event. <br /><br />These key-value pairs adds structure to Events, making it easier to search structured data. Attributes can be nested JSON objects, however, we recommend limiting the amount of nesting.
`rawstring`     | no            | The raw string representing the Event. The default display for an Event in Humio is the `rawstring`. If you do not provide the `rawstring` field, then the response defaults to a JSON representation of the `attributes` field.
`kvparse`       | no            | If you set this field to true, then Humio parses the `rawstring` field looking for key-value pairs of the form `a=b` or `a="hello world"`.

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
    "rawstring": "starting service=coordinator transactionid=42",
    "kvparse" : true
}
```

#### Response

Standard HTTP response codes.

#### Example

``` shell
curl $BASEURL/api/v1/dataspaces/$REPOSITORY_NAME/ingest \
 -X POST \
 -H "Content-Type: application/json" \
 -H "Authorization: Bearer $API_TOKEN" \
 -d '[{"tags": {"host":"myserver"}, "events" : [{"timestamp": "2016-06-06T12:00:00+02:00", "attributes": {"key1":"value1"}}]}]'
```

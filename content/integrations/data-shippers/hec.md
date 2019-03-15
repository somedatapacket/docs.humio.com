---
title: "HTTP Event Collector"
weight: 200
categories: ["Integration", "DataShipper"]
categories_weight: -90
---

Humio's HEC API is an alternative HTTP ingest endpoint.

You will find it at `/api/v1/ingest/hec` and at `/services/collector`


### Format of data

Ingested data is a series of _whitespace delimited_ JSON objects, containing one or more of the following elements.  All elements are optional.

|member|description|
|------|-----------|
|`"time"`|Time in seconds since January 1, 1970 in UTC.  This can be a decimal or real number to support milliseconds. Humio represents time with millisecond precision. |
|`"timezone"`|Can be used to describe the time zone in which the event happened. Defaults to `Z`, i.e. UTC.|
|`"index"`| Optional name of the repository to ingest into.  In public-facing API's this must -- if present -- be equal to the repository used to create the ingest token used for authentication. In private cluster setups, humio can be configured to allow these to be different. See below.|
|`"sourcetype"`| Translated to `#type` inside Humio.  If set, this is used to choose which Humio parser to use for extracting fields|
|`"source"`| Translated to the `@source` field in Humio.  Typically used to designate the path to the file that is being shipped to Humio. |
|`"host"`| Translated to the `@host` field in Humio. Typically used to designate the origin host.|
|`"event"`| This can be either a _JSON Object_ or a _String_. Translated to the `@rawstring` field in Humio.  When this is a JSON Object, all members of the object will become accessible fields in humio with no further processing.  If it is a string, the key/value parser is always applied to the string to extract elements. The key/value parser searches for `key=value`, `key="value"` or `key='value'` |
|`"fields"`| JSON object containing extra fields to the event.  This can be used if `"event"` is a string and it is pre-processed prior to ingest to extract fields.  Tags `#tags` can be added to the event by specifying fields starting with `#`.  |




### Authentication

You will need to provide a [Humio Ingest Token](https://docs.humio.com/sending-data-to-humio/ingest-tokens/) in the HTTP `Authorization` header.

The ingest token contains the name of the repository the data stored in, and ingested events will be stored in the repository corresponding to the ingest token.

If the Humio configuration variable `ALLOW_CHANGE_REPO_ON_EVENTS=true` is set, then HEC allows ingest to any repository specified as `"index": "<repository-name>"` in the body of a message, as long as the ingest token is valid for any existing repository on the humio server.  This is a potential security issue on a public API endpoint, so this option should only be used inside a trusted environment.

### Example

```
cat << EOF > events.json
{
  "time" : 1537537729.0,
  "event" : "Fri, 21 Sep 2018 13:48:49 GMT - system started name=webserver",
  "source" : "/var/log/application.log",
  "sourcetype" : "applog",
  "fields" : {
    "#env" : "prod"
  }
}

{
  "time" : 1537535729.0,
  "event" : {
    "message" : "System shutdown",
    "host" : {
      "ip" : "127.0.0.1",
      "port" : 2222
    }
  },
  "fields" : { "#datacenter" : "amazon-east1" }
}
EOF

curl $BASEURL/api/v1/ingest/hec \
 -X POST \
 -H "Content-Type: text/plain; charset=utf-8" \
 -H "Authorization: Bearer $API_TOKEN" \
  --data "@events.json"
```
You must make the following changes to the sample configuration:

* Add other fields in the fields section. These fields, and their values, will be added to each event.

* Insert the URL containing the Humio host in the `$BASEURL` field . For example `https://cloud.humio.com`

* `$INGEST_TOKEN` - is the [ingest token](/sending-data-to-humio/ingest-tokens/) for your repository, (e.g. a string such as `fS6Kdlb0clqe0UwPcc4slvNFP3Qn1COzG9DEVLw7v0Ii`).

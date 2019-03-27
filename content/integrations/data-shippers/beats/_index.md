---
title: "Elastic Beats"
category_title: "Overview"
heading: "Humio & Elastic Beats"
weight: 100
categories: ["Integration", "DataShipper"]
pageImage: /integrations/elastic.svg
---

The [OSS Elastic Beats](https://www.elastic.co/products/beats) are a
great group of data shippers. They are cross-platform, lightweight, and can ship data to a number of tools **including Humio** as long as you stick to the **OSS** builds.

All Beats are built using the [libbeat library](https://github.com/elastic/beats). Along with the official Beats, there are a growing number of
[community Beats](https://www.elastic.co/guide/en/beats/libbeat/current/community-beats.html).


## Available Beats

{{% notice note %}}
Starting from version 6.7.0 of the libbeat only the OSS versions can ship to Humio. The non-OSS beats check that the server is a licensed elastic server due to this change to the beats client library: ["Check license x-pack"](https://github.com/elastic/beats/pull/11296)
{{% /notice %}}

There are currently five official Beats. The Elastic documentation site and Humio's documentation offer resources that describe how to use each of them.

* **[Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)** - Ships regular log files.
    * [Get Started](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html)
    * [Humio's Filebeat documentation](/sending-data/data-shippers/beats/filebeat/)

* **[Metricbeat](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html)** - Ships metrics from your OS and common services.
    * [Get Started](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-getting-started.html)
    * [Humio's Metricbeat documentation]({{< ref "metricbeat.md" >}})

* **[Packetbeat](https://www.elastic.co/guide/en/beats/packetbeat/current/index.html)** - Analyzes network packets and common protocols like HTTP
    * [Get Started](https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-getting-started.html)

* **[Winlogbeat](https://www.elastic.co/guide/en/beats/winlogbeat/current/index.html)** - Ships Windows event logs
    * [Get Started](https://www.elastic.co/guide/en/beats/winlogbeat/current/winlogbeat-getting-started.html)

* **[Heartbeat](https://www.elastic.co/guide/en/beats/heartbeat/current/index.html)** - Checks system status and availability
    * [Get Started](https://www.elastic.co/guide/en/beats/heartbeat/current/heartbeat-getting-started.html)

{{% notice note %}}
***Community Beats***
In addition, the Elastic community has created many other Beats that you can download and use.  
These [Community Beats](https://www.elastic.co/guide/en/beats/libbeat/current/community-beats.html) cover many less common use cases.
{{% /notice %}}

## General Output Configuration

All beats are built using the [libbeat library](https://github.com/elastic/beats) and
share output configuration.  Humio supports parts of the ElasticSearch
ingest API, so to send data from Beats to Humio, you just use the
[ElasticSearch output](https://www.elastic.co/guide/en/beats/filebeat/current/elasticsearch-output.html)
(the documentation is identical for all Beats).

You can use the following `elasticsearch` output configuration template:

``` yaml
output:
  elasticsearch:
    hosts: ["$BASEURL/api/v1/ingest/elastic-bulk"]
    username: $INGEST_TOKEN
```

{{< partial "common-rest-params" >}}

{{% notice note %}}
To optimize performance for the data volumes you want to send, and to keep shipping latency down, change the default settings for `compression_level`, `bulk_max_size` and `flush_interval`.
{{% /notice %}}

## Adding fields

All Beats also have a `fields` section in their configuration. You can add fields to all events by specifying them in the `fields` section:

``` yaml
fields:
    service: user-service
    datacenter: dc-a
```


### Ingesting to multiple repos using a single ingest token

If the Humio configuration variable `ALLOW_CHANGE_REPO_ON_EVENTS=true`
is set, then Humio allows ingest to any repository specified as `#repo
= <repository-name>` in the tags of an event, as long as the ingest
token is valid for any existing repository on the humio server. The
`#repo` can also be set by the parser for the same effect as if the
value was provided by the original shipper. If the named repo does not
exist then the event remains in the repo designated by the ingest
token.

This is a potential security issue on a public API endpoint, so this
option should only be used inside a trusted environment. For the same
reason this feature is not enabled on cloud.humio.com.

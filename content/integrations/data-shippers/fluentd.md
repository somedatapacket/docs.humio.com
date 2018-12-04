---
title: "FluentD"
weight: 300
categories: ["Integration", "DataShipper"]
pageImage: /integrations/fluentd-logo.png
---

## Installation

To install FluentD please refer to the [FluentD Downloads Page](https://www.fluentd.org/download) with installation guides.

## Configuration

{{% notice info %}}
For the full documentation on FluentD please see the [official documentation](https://docs.fluentd.org/v1.0/articles/quickstart).
{{% /notice %}}

## Elastic Output Plugin

Some of the most commons parameters in the [Elasticsearch Output Plugin](https://docs.fluentd.org/v1.0/articles/out_elasticsearch) are

* `host`: The hostname of your Humio instance.
* `port`: The port of where Humio is exposing the Elastic Endpoint. Don't forget to enable `ELASTIC_PORT` the [Configuration parameter]({{< ref "configuration" >}}).
* `scheme`, `ssl_version`: Depending on whether TLS is enabled on `host`:`port`, this should be set to either `https` or `http`. Humio Cloud has TLS enabled. In [some cases](https://github.com/uken/fluent-plugin-elasticsearch/issues/439) it is necessary to specify the SSL version.
* `user` and `password`: while `password` can be ignore, but must be present, `user` should be set to an [ingest token]({{< ref "/sending-data-to-humio/ingest-tokens.md" >}}).


### Output Plugin configuration for [Humio Cloud](https://cloud.humio.com/)

```
<match **>
  @type           elasticsearch
  host            cloud.humio.com
  port            9200
  scheme          https
  ssl_version     TLSv1_2
  user            ${MyIngestToken} # Replace with your actual ingest token
  password        ignore
  logstash_format true
</match>
```

### Output Plugin configuration for on-prem

```
<match **>
  @type           elasticsearch
  host            humio.acme.local
  port            9200
  scheme          http
  user            ${MyIngestToken} # Replace with your actual ingest token
  password        ignore
  logstash_format true
</match>
```

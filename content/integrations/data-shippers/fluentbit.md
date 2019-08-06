---
title: "Fluent Bit"
weight: 300
categories: ["Integration", "DataShipper"]
pageImage: /integrations/fluentbit.png
draft: true
---

[Fluent Bit](https://fluentbit.io) is an open source and multi-platform Log Processor and Forwarder which allows you to collect data/logs from different sources, unify and send them to multiple destinations. It's fully compatible with Docker and [Kubernetes]({{< ref "/integrations/platform-integrations/kubernetes" >}}) environments.

Humio has full support for Fluent Bit if you enable the `ELASTIC_PORT` [Configuration parameter]({{< ref "/operations-guide/configuration" >}}).

## Installation

To install Fluent Bit, visit the [Fluent Bit Downloads page](https://fluentbit.io/download/).

## Configuration

{{% notice info %}}
For the full documentation on Fluent Bit please see the [official documentation](https://docs.fluentbit.io/manual/).
{{% /notice %}}

### Elastic Output plugin

```
[OUTPUT]
    Name        es
    Match       *
    HTTP_User   ${ingest-token}
    HTTP_Passwd ignore
    Host        ${host}
    Port        ${port}
```


### SSL enabled endpoints

```
[OUTPUT]
    …
    tls         on
```

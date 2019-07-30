---
title: "Humio Metrics"
weight: 100
show_functions_as_pages: true
---

Humio outputs a number of metrics that can be used to monitor and
operate Humio itself.

The metrics are available in different ways.

### JMX

Humio can expose all metrics over JMX. To enable it, you need to set the standard JMX options to your JVM by adding them to the [HUMIO_JVM_ARGS]({{< ref"configuration/_index.md#example-configuration-file-with-comments" >}}) configuration configuration.

Example:
```
HUMIO_JVM_ARGS=-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false  -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=5000
```


### Prometheus

Setting the [PROMETHEUS_METRICS_PORT]({{< ref "configuration/_index.md#example-configuration-file-with-comments" >}}) configuration will enable Prometheus to scrape metrics from Humio.

### Humio debug logs

The debug log of Humio also contains all the metrics. You can find
them in the `humio` repository or the special [humio-metrics]({{< ref "glossary/repositories.md#the-humio-metrics-repository" >}})
repository


## Metric Types

There are two types of metrics in Humio, [node level
metrics](#node-level-metrics) and [objects level
metrics](#object-level-metrics). The last type is for objects such as
repositories, ingest listeners, or storage partitions. An example of
an object level metric is `ingest-bytes/<repo>`. Here `<repo>` is a
placeholder for a concrete repository in a given Humio system.

{{% metrics %}}

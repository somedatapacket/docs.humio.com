---
title: "Data Shippers"
weight: 5
category_title: "Overview"
---

Humio is compatible with the most popular open-source data shippers.

A log shipper is small tool that functions as the glue between your system and Humio, which makes it possible to
transfer log files and metrics easily and reliably.

Using a log shipper has many benefits compared to using the [direct Ingest REST]({{< relref "http_api.md#ingest" >}}),
e.g. data is retransmitted on failure and messages can be batched.

We always recommend using the [beats]({{< relref "sending_logs_to_humio/log_shippers/beats/_index.md" >}})
as these tools are both modern and very mature. It is what we use for many of our own systems.

Currently we offer support for the following data shippers
{{% children %}}

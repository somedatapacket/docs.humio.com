---
title: "Data Shippers"
weight: 100
category_title: "Overview"
---

Humio is compatible with most popular open-source data shippers.

A log shipper is small tool that functions as the glue between your system and Humio making it possible to
transfer log files and metrics easily and reliably.

Using a log shipper has many benefits compared to using the [Ingest API]({{< relref "ingest-api.md" >}}) 
including the fact that data can be retransmitted on failure and messages can be batched.

We always recommend using the [Beats]({{< relref "integrations/data-shippers/beats/_index.md" >}})
as these tools are both modern and very mature. We use Beats for many of our own systems.

Currently we offer support for the following data shippers:
{{% children %}}

---
title: Datasources
---

A Data Source is a set of [Events]({{< ref "events.md" >}}) that have the same [Tags]({{< ref "tags.md" >}}).
Humio divides each [Repository]({{< ref "repositories.md" >}}) into more than one Data Source.

Humio creates Data Sources automatically when it encounters a new combination of Tags. Users cannot create Data Sources directly.

Data Sources are the smallest unit of data that you can delete.
You cannot delete individual Events in a Data Source beyond expiration.<!--GRW: I'm not sure what 'beyond expiration' means. -->

Humio represents each Data Source internally as a dedicated directory within the Repository directory.

{{% notice note %}}
We recommend that you _do not create more than 1,000 separate tags_, or combinations of tags.
If you need more combinations we recommend that you use attributes on individual
events to differentiate them and select them separately.
{{% /notice %}}

Each Data Source requires Java heap for buffering while building the
next block of data to be persisted. This amount to roughly 5 MB each. If you have 1,000 Data Sources (across all repositories, in total) on your Humio server, you will need at least 5GB of heap for that on top of the other heap being used. In a clustered environment, only the share of Data sources that are being "digested" on the node need heap for buffers. So more servers can accommodate more Data Sources in the cluster.


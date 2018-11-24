---
title: Datasources
---

A Data Source represents one stream of events from a log source. An example is the "syslog" from a server, or the access log from a web server.

But how does Humio which Data Source a set of events belong to? This
is determined by inspecting the [Tags]({{< ref "tags.md" >}}). Thus a
Data Source really is a set of [Events]({{< ref "events.md" >}}) that have
the same [Tags]({{< ref "tags.md" >}}).  Humio divides each
[Repository]({{< ref "repositories.md" >}}) into more than one Data
Source based on the Tags.

Humio creates Data Sources automatically when it encounters a new combination of Tags. Users cannot create Data Sources directly.

Data Sources are the smallest unit of data that you can delete.
You cannot delete individual Events in a Data Source, but you can set "retention" on the repository to allow deleting events when the reach a certain age.

Humio represents each Data Source internally as a dedicated directory within the Repository directory.

{{% notice note %}}
We recommend that you _do not create more than 1,000 separate tags_, or combinations of tags.
If you need more combinations we recommend that you use attributes on individual
events to differentiate them and select them separately.
{{% /notice %}}

## Advanced topics

For most use cases you can ignore the following section.

For performance reasons the amount of data that flow into each Data
Source is limited to approximately 5 MB/s on average. The exact
amount depends on how much a single CPU core can "Digest". If a Data
Source receives more data for a while, then Humio turns on "auto
sharding". This adds a synthetic tag value for the tag
"#humioAutoShard" to split the stream into multiple data sources. This
process is fully managed by Humio.

For optimal performance a Data Source should receive 1 KB/s or more on
average. If you know you have many Data Sources in a repository that
are slow in this respect, you can get better performance by turning on
"Tag Grouping" on the tags that identify the slow streams.

Each Data Source requires Java heap for buffering while building the
next block of data to be persisted. This amount to roughly 5 MB each. If you have 1,000 Data Sources (across all repositories, in total) on your Humio server, you will need at least 5GB of heap for that on top of the other heap being used. In a clustered environment, only the share of Data sources that are being "digested" on the node need heap for buffers. So more servers can accommodate more Data Sources in the cluster.


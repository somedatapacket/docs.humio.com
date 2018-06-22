---
title: Tags
---

{{% notice warning %}}
Tags are an **advanced feature**. You should see that you have performance
issues before considering adding custom tags. If not used appropriately they
can adversely impact performance and increase resource usage.
{{% /notice %}}

Tags are important for the performance of your searches, so it makes sense to understand them a little better.

Humio saves data in [Data Sources]({{< ref "datasources.md">}}), which are defined by their tags.
Tags are special attributes who's names start with `#`.
In most cases, your data should have a `#type` tag, as that tag controls which parser is
used to interpret the raw text in the log entry, in particular how to parse the time stamp if possible.

When you configure various ways to ingest data, you have the opportunity to define extra tags.

- For parsers, you can specify fields that will get turned into tags.
- For filebeats configurations, you can add tags as part of the filebeat configuration that will be added to all
  log entries coming via that configuration.
- For ingest listeners you can specify tags.
- When using the HTTP ingest API, you can specify tags to be added to your data.

As data is ingested, the tags control which data source it is assigned to. And likewise when you make a search,
you can include `#tag=value` filter expressions in your search.  Such filter elements are pre-processed before the
actual serch is performed to choose which data sources to scan.  As such, adding tags also speeds up your searches
-- if you also use the tags in your searches.

Each uniq combination of tags create a data source, and each data source creates a directory with the data in that
data source.  If you create too many different tag combinations, then performance also goes bad again.
You can read some more about tags and datasources in the blog post [here.](https://medium.com/humio/understanding-humios-data-sources-a23db019a90f).

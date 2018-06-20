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

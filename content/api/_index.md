---
title: "API"
category_title: Overview
weight: 900
---

Here are some quick links to get you started using Humio's API:

- [Authentication]({{< relref "api_tokens.md" >}})
- [Search API]({{< relref "search-api.md" >}})
- [Ingest API]({{< relref "ingest-api.md" >}})

Everything you can do in Humio's UI can be done through our HTTP API as well.
In fact, the UI is constructed using solely the public API.


## REST and GraphQL

Humio has a mixture of GraphQL and REST endpoint. You can read about the
[motivation of using GraphQL]({{< relref "graphql.md" >}}),
as well as an introduction to GraphQL if you are not familiar.

{{% notice info %}}
We are in the process of migrating most of our API to GraphQL, but there are
still parts that remain REST. You should prefer the GraphQL version if an API
offers both a REST and a GraphQL version. **Many REST endpoints will become
deprecated**, but we continue to support them for the foreseeable future.
{{% /notice %}}

---
title: "Others Data Shippers"
weight: 1000
---

If your favorite data shipper is not available changes are it is still compatible
or configurable enough to send data to Humio.

Humio supports the following APIs for data ingestion:

- [Humio's Ingest API]({{< ref "#humio-api" >}})
- [ElasticSearch Bulk API]({{< ref "#elastic-api" >}})

## Humio's Ingest API {#humio-api}

Humio has an [Ingest API]({{< ref "ingest-api.md" >}}).  You can use this
to build an integration towards Humio.

## ElasticSearch Bulk API {#elastic-api}

Humio is compatible with the [ElasticSearch Bulk ingest API](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html).

If you have a log shipper that supports the ElasticSearch Bulk API,
there is a good change that you can use this to send logs to Humio.
See the [Beats documentation]({{< ref "sending-data/data-shippers/beats/_index.md" >}}) for an example of
configuration options.

Contact us if you have trouble getting this working e.g. getting errors when trying
to make a client work against the API.

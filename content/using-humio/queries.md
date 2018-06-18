---
title: Queries
---

### Aggregate Queries {#aggregate}
_Aggregate queries_ are queries that join the Events into a new structure of [events]({{< ref "events.md" >}}) with attributes.

A query becomes an _aggregate query_ if it uses an aggregate function
like {{% function "sum" %}}, {{% function "count" %}} or {{% function "avg" %}}.
See [functions]({{< relref "query-functions/_index.md" >}}) for more information.

For example, the query `count()` takes a stream of Events as its input, and
produces one Event containing a `count` attribute.


### Transformation Queries {#filter}

_Filter queries_, or _non-aggregate queries_, are queries that only filter
Events, or add or remove attributes on each event.

These queries can only contain filters and transformation functions
(see [functions]({{< relref "query-functions/_index.md" >}}))


### Live Queries {#live}

Live queries provide a way to run searches that are continuously
updated as new Events arrive. Live queries are important for creating dashboards,
and many other uses.

Humio uses an efficient streaming implementation to provide this feature.

In a live query, the time interval is a time window relative to 'now', such
as 'the last 5 minutes' or 'the last day'.

Humio sets the {{% function "groupBy" %}} attribute of a live query automatically.
It bases the grouping on buckets that each represent a part of the given time interval.

Aggregate queries run live inside each bucket as Events arrive. Whenever the current
response is selected, it runs the aggregations for the query across the buckets.

{{% notice note %}}
Humio purges live queries if no client has checked their status for 60 minutes.
{{% /notice %}}

### Query Boundaries {#boundaries}

The term *query boundary* means those aspects of a query that
Humio uses to select the data that it scans to produce the query result.

The query boundary consists of a repository, a time interval and a set of tags.

In the Humio interface, you can set the time interval using a special selector.
The Tags should preferably be at the start of the query string.
For example, `#tagname=value`.

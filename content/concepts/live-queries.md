---
title: Live Queries
---

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
Humio automatically stops live queries if no client has checked their status in a while.
{{% /notice %}}

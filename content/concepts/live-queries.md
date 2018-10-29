---
title: Live Queries
aliases: ["/glossary/"]
---

Live queries provide a way to run searches that are continuously
updated as new Events arrive. Live queries support showing data in real time and are important for creating dashboards,
and have many other uses.

Humio uses an efficient streaming implementation to provide this feature.

In a live query, the time interval is a time window relative to 'now', such
as 'the last 5 minutes' or 'the last day'.  
A live query will start doing a historical query as well as setting up the live streaming part. New events are pushed into the streaming query.

Humio splits live queries into buckets. Each bucket represents a part of the given time interval.
As time passes, buckets will slide out of the search interval, and new buckets will be created.
Aggregate queries run live inside each bucket as Events arrive. Whenever the current
response is selected, it runs the aggregations for the query across the buckets.


The server keeps live queries running. This way results are immediately ready when opening a dashboard with running live queries.  
If live queries are not polled the server will stop them at some point. The following describes when live queries are stopped:

* Live queries on dashboards will be kept running on the server for 3 days if they are not polled. 
This is configurable using the configuration parameter `IDLE_POLL_TIME_BEFORE_DASHBOARD_QUERY_IS_CANCELLED_MINUTES`.
* Live queries are kept running for 1 hour if they are not polled.
* All live queries that have not completed their historical search part will be closed if they are not polled for 30 seconds. Just like historical queries are.

The UI will try to stop live queries, when they are not used anymore. When submitting a new search, the previous one will be stopped etc. 


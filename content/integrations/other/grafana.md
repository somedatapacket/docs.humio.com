---
title: Grafana
weight: 700
---

Humio has built-in support for dashboards, but if you are using Grafana for
visualizing your data from different sources and would prefer to keep everything
in Grafana you can use Humio's Grafana plugin:

https://github.com/humio/humio2grafana

## Tip: Use Saved Query

It is a good idea to create and maintain the queries you use in your Grafana
dashboards in Humio's UI. Then create Saved Queries for them and call them
by name in Grafana instead of writing the entire query in Grafana.

**Example**

Create a query and give it the name "MyQuery":

```humio
#source=console.log loglevel=ERROR | timechart()
```

Then from Grafana call it by name, i.e.:

```humio
$MyQuery()
```

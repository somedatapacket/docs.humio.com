---
title: Queries
---

A Humio query is much like a query to an SQL database. You write search terms
to include or exclude values from a repository or view.
Unlike most queries SQL, in Humio, you also do calculations and transform the
data as part of the query.

To learn Humio's query language head over to the [language syntax documentation page]({{< ref "language-syntax/_index.md" >}}).

Some filter, some transform and augment, others aggregate data into
result sets like tables or bucketed time series.


## Transformation Queries {#filter}

Transformation expressions (also called _Filter expressions_) filter
input or adds/removes/modifies fields on each event.
These include filter expressions like:

```humio
name = "Peter" and age > 25
```

```humio
color := "blue"
```

A subset of the available query functions are known as _Transformation Functions_,
e.g. {{% function "regex" %}}, {{% function "in" %}} or {{% function "eval" %}}.
Just like the examples above they only adds/removes/modifies fields and never produce
new (additional) events as output.

If a query consists solely of transformation expressions it is known as
_filter query_ or _transformation query_. This kind of query are required e.g. when
connecting [views]({{< ref "views.md" >}}) with repositories.

## Aggregation Queries {#aggregate}

_Aggregation expressions_ are always function calls. These functions can combine
their input into a new structures or emit new events into the output stream.

A query becomes an _aggregation query_ if it uses at least one aggregate function
like {{% function "sum" %}}, {{% function "count" %}} or {{% function "avg" %}}.

For example, the query {{< query >}}count(){{< /query >}} takes a stream of events as its input,
and produces a single record containing a `_count` field.

***Examples***

```humio
loglevel = ERROR | timechart()
```

```humio
x := y * 2 | bucket(function=sum(x))
```

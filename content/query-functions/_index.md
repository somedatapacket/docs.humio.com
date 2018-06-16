---
title: "Query Functions"
weight: 600
---

Query functions are specified using a name followed by brackets containing parameters.
Parameters are supplied as named parameters

```humio
sum(field=bytes_send) // calculate the sum of the field bytes_send
```

Functions are allowed to have one `unnamed parameter`. The {{% function "sum" %}}
function accepts the field parameter as unnamed parameter and can be written as
{{< query >}}sum(bytessend){{< /query >}}.

A function is either a **Transformation function** or an **Aggregate Function**.

*Transformation Functions* (also sometimes referred to as Filter Functions) can
filter events and add, remove and modify fields.

*Aggregate Functions* combine events into a new results - often a single number
or row. For example function {{% function "count" %}} returns one event with one field `_count`.

Each query function is described below:

{{% queryfunctions %}}

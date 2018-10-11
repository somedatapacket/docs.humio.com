---
title: Gauge Widget
---

The _world map_ widget can display geographical data on a world map. Different
map projections are supported such as the standard mercator or orthographic projection.

## Input Format

The Guage Widget can any data with at least one field containing a number.
It multiple rows are present in the input, the first element is used.
If multiple number fields are present, it is unspecified which field is used.

## Usage

The Gauge Widget is best used in conjunction with functions such as {{< function "sum" >}}, {{< function "count" >}},
or {{< function "avg" >}} which produce a single row with a single field, e.g. `_sum`.

### Example 1: Counting Errors

```humio
loglevel =~ /error/i | count()
```

---
title: "Limits"
weight: 1
---

This page gives a table over the various limits that exists in Humio

Limit table:

| Description | Limit | Notes |
|-------------|-------|-------|
| Max number of fields in an event| 1000 |
| Max event size | 1M bytes |
| Max length of query | 66k characters|
| Max number of elements in a [groupby]({{< ref "/query-functions/_index.md#groupBy">}}) | 20k | Can be disabled using the `ALLOW_UNLIMITED_STATESIZE` configuration
| Max number of datasources in a repository | 10k | Can be changed using the `MAX_DATASOURCES` configuration

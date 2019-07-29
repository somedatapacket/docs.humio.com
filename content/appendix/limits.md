---
title: "Limits"
weight: 1
---

This page lists the various limits that Humio has.


### General limits

| Description | Limit | Notes |
|-------------|-------|-------|
| Max number of fields in an event| 1000 | Can be changed using the `MAX_EVENT_FIELD_COUNT` configuration|
| Max event size | 1M bytes |
| Max length of query | 66k characters|
| Max number of elements in a [groupby]({{< ref "/query-functions/_index.md#groupBy">}}) | 20k | Can be changed using the `MAX_STATE_LIMIT` configuration
| Max number of events in a [tail]({{< ref "/query-functions/_index.md#tail">}}) | 10k | -
| Max number of datasources in a repository | 10k | Can be changed using the `MAX_DATASOURCES` configuration


### [cloud.humio.com](https://cloud.humio.com) specific limits

| Description | Limit | Notes |
|-------------|-------|-------|
| Max body size in POST requests | 32M bytes | this will mainly be hit when ingesting large bulks of events.

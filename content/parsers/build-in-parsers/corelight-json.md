---
title: corelight-json
---

Built in parser that supports [Corelights](https://www.corelight.com/) Bro sensors.

Corelight sensors have out of the box support for streaming out the Bro logs.
Humio can receive the streaming data using this
parser and [ingest listeners]({{< ref "cluster-management-api.md#adding-a-ingest-listener-endpoint" >}}).

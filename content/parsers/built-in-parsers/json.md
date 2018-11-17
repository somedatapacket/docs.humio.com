---
title: json
---

This parser can process JSON data in log lines.

It expects to find a JSON property called `@timestamp` containing a
[ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) formatted time string.

If you don't have control over the JSON format
you can [create a custom JSON parser]({{< ref "creating-a-parser.md#json" >}}).

## Example Input
``` json
{
  "@timestamp": "2017-02-25T20:18:43.598+00:00",
  "loglevel": "INFO",
  "service": {
	"name": "user service",
	"time": 123
  }
}
```

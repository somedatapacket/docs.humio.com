---
title: kv-millis
aliases: ["/parsers/built-in-parsers/kv-millis"]
---

This parser, like the [kv]({{< ref "kv.md" >}}) parser, this is a key-value parser.
However, it expects the timestamp in the log line to be UTC time in milliseconds.

## Example Input

```
1488054417000 created a new user user="John Doe" service=user-service as a freemium user
```

Given the above log line, Humio parses the fields `user=John Doe` and `service=user-service`.

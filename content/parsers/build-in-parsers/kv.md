---
title: kv
---

This parser is the key-value parser. It can process standard key-value patterns in log lines.  
It expects the log line to start with a date in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) formatting.
The parser processes the rest of the line for key-value pairs.

### Example Input

```
2017-02-25T20:18:43.598+0000 created a new user user="John Doe" service=user-service as a freemium user
```

Given the above log line, Humio parses the fields `user=John Doe` and `service=user-service`.

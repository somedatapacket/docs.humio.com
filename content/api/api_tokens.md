---
title: "Authentication"
weight: 200
---

All but a few of Humio's API endpoints require authentication. Clients have to
provide an API Token along with each request in form of a `Bearer Token`.

You provide your API token in a HTTP header like e.g.:

```
Authorization: Bearer $API_TOKEN
```

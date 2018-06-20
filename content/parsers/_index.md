---
title: "Parsers"
category_title: "Overview"
date: 2018-03-15T08:19:58+01:00
weight: 650
---
Humio uses parsers to extract the structure from the data that you send to it.

For example, each line from a standard web server log file has status code,
method, and URL fields.

When you send data to Humio, you must specify a parser that tells Humio how to
understand the data.

Humio comes with some built-in parsers. These parsers can process common formats
like web server access logs from the Apache and Nginx servers.

If the built-in parsers do not support your data type, then you can create
your own.

Humio supports two types of parsers:

* [JSON Parsers]({{< ref "json-parsers.md" >}})
* [Regular Expression Parsers]({{< ref "regexp-parsers.md" >}})

We also have an API for managing parsers: [Parsers API]({{< relref "parser-api.md" >}}).

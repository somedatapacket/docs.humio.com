---
title: "Parsers"
category_title: "Overview"
date: 2018-03-15T08:19:58+01:00
weight: 650
---

When data arrives at Humio for ingestion it needs to be parsed before it is stored in a repository.
A parser takes text or JSON data as input and extracts the special [`@timestamp` field]({{< ref "events.md#timestamp" >}}) and custom
[user fields]({{< ref "events.md#user-fields" >}}) from the data.

For example, each line from a standard web server log file has status code,
method, and URL fields.

You have to specify which parser should be used on the client side. Exactly how
this is done, depends on [how you send your logs to Humio]({{< ref "sending-data-to-humio/_index.md" >}}).
E.g. if you are using Filebeat you specify the parser by setting the special `@type` field in the
configuration.

{{% notice tip %}}
We also have an API for managing parsers: [Parsers API]({{< ref "parser-api.md" >}})
{{% /notice %}}

## Built-in Parsers

Humio comes with a set of [built-in parsers]({{< ref "parsers/built-in-parsers/_index.md" >}}) for
common log formats, like e.g. accesslog.

## Custom Parsers

If the built-in parsers do not support your data type, then you can create
your own.

Humio supports two types of custom parsers:

* [JSON Parsers]({{< ref "json-parsers.md" >}})
* [Regular Expression Parsers]({{< ref "regexp-parsers.md" >}})

Next Step: [Creating a Custom Parser]({{< ref "creating-a-parser.md" >}})

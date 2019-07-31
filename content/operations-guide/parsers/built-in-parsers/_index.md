---
title: "Built-in Parsers"
category_title: Overview
weight: 100
aliases: ["/parsers/built-in-parsers"]
---

Humio supplies built-in parsers for common log formats. For example it includes
a parser for the widely-used [accesslog](https://httpd.apache.org/docs/2.4/logs.html#accesslog)
format for web servers like Apache and Nginx.

This page lists and describes each of the built-in parsers.

When shipping data to Humio, check if there is a built-in parser for the logs
before writing a custom parser.
The built-in parsers are also a good starting point when creating custom parsers.

See the [parsing]({{< ref "parsers/_index.md" >}}) page for an overview of how parsers work.

You can examine each of the built-in parsers directly in the Humio UI. Just
open its page and check the supported regular expression and timestamp formats.
When you paste in test data Humio shows the result of parsing.

{{%children%}}

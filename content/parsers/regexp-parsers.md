---
title: RegExp Parsers
weight: 300
---

Regular Expression Parsers (RegExp Parsers) let you parse incoming data using
regular expressions. Humio extracts fields using _named capture groups_ -
feature of regular expressions that allows you to name sub-matches, e.g:

```
(?<firstname>\S+)\s(?<lastname>\S+)
```

This defines a parser that expects input to contain names, first and last. It then extracts
the first and last names into two fields `firstname` and `lastname`. The `\S` of course means
any character that is not a whitespace and `\s` is a whitespace character.

When creating a regex parser you always have to extract a field called `@timestamp`.
Here is an example:

```
(?<@timestamp>\S+\s\S+)\s(?<rest>.*)
```

This creates two fields `@timestamp` and `rest`.

You must also specify a timestamp format. Humio uses this to parse the extracted timestamp.
See the section below on [parsing timestamps]({{< ref "creating-a-parser.md#parsing-timestamps" >}}).

It is a good idea to reference some of the built-in parsers when creating your first regex parser,
to see who they are defined.

{{% notice tip %}}
***Testing***  
You can test the parser on the **Parser** page by adding some test data. This offers an interactive way to refine the parser.
See the section on [Testing the Parser]({{< ref "creating-a-parser.md#testing" >}}) section below.
{{% /notice %}}

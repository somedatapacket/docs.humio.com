---
title: Creating a Parser
weight: 100
---

If no built-in parsers match your needs, then you can create your own.
This page will guide you through the process of creating a custom
parser.

## List of Parsers

Go to the **Parsers** subpage in your repository to see all the available parsers:

![Parsers List`](/images/parsersx.png)

### Built-in parsers

The first part of the list contains [built-in parsers]({{< ref "parsers/built-in-parsers/_index.md" >}}).

You cannot delete the built-in parsers, but you can overwrite them if you want.
You can also copy existing parsers to use as a starting point for creating new parsers.

## The Parser User Interface

The following screenshots shows the **Parser** page with a custom parser called `humio`:

![Custom Parser`](/images/custom-parser.png)

The **Parser** page lets you define and test parsers.

{{% notice tip %}}
Click the tooltips ('?') next to each field for information on their purpose.
{{% /notice %}}

Let's walk through the different steps in creating a parser:

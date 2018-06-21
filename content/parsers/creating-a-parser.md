---
title: Creating a Parser
weight: 200
---

If no built-in parsers match your needs, then you can create your own.
This page will guide you through the process of creating a custom
parser.

## List of Parsers

Go to the **Parsers** subpage in your repository to see all the available parsers:

{{% figure src="/images/parsersx.png" width="600px" %}}

### Built-in parsers

Apart from custom parsers the list also contains [built-in parsers]({{< ref "parsers/built-in-parsers/_index.md" >}}).

You cannot delete the built-in parsers, but you can overwrite them if you want.
You can also copy existing parsers to use as a starting point for creating new parsers.

## The Parser User Interface

The following screenshots shows the **Parser** page with a custom parser called `humio`:

{{% figure src="/images/custom-parser.png" width="600px" %}}

The **Parser** page lets you define and test parsers.

{{% notice tip %}}
Click the tooltips ('?') next to each field for information on their purpose.
{{% /notice %}}


## Timestamps {#parsing-timestamps}

The default timestamp format is [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601),
with the format `yyyy-MM-dd'T'HH:mm:ss[.SSS]XXX`. Milliseconds are optional, and `XXX` specifies the timezone offset.

If the timestamps in the data are in local time, and do not have a time zone, then you can specify the time zone manually.
The **Timezone** input field becomes editable when the timestamp format does not have a time zone designator.

{{% notice note %}}
***Timestamp format***  
Look at [Java's DateTimeFormatter documentation](https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html) for details on how to define the timestamp format.
{{% /notice %}}

{{% notice note %}}
***timestamp in milliseconds***  
You can specify `millis` in the timestamp format. This specifies that the time is in milliseconds (Epoch time in milliseconds).
{{% /notice %}}

## Key-value Parsing {#key-value}
When creating a regular expression parser, you can add key-value parsing.
When you enable key-value parsing, Humio runs an extra parser on the incoming event.
This extra parser looks for key-value fields of the form:

 * `key=value`
 * `key="value"`
 * `key='value'`

So for a log line like this:

`2017-02-22T13:14:01.917+0000 [main thread] INFO  UserService -  creating new user id=123, name='john doe' email=john@doe`

 The key-value parser extracts the fields:

 * `id: 123`
 * `name: john doe`
 * `email: john@doe`

As developers start to use Humio, they can start to use the key-value pattern when logging. This gives a lot of structure to the logs in Humio.


## Testing the Parser {#testing}

The parser page supports testing the parser. Paste a snippet of your logs and run the parser.

{{% notice note %}}
***Building the regular expression***  
When creating the regular expression, we recommend that you build it one group at a time, and test it after each change.
{{% /notice %}}

When you run the parser, Humio shows a list of parsed events. You can expand each event and see the extracted fields.
Events are colored red if they could not be parsed and the first error message is displayed above the result list.

{{% notice note %}}
***Testing the `timestamp` field***  
The `@timestamp` field displays in milliseconds (UTC). This makes it hard to determine if the timestamp is parsed correctly.
A formatted timestamp is shown on the gray bar at the top of the details for the event.
{{% /notice %}}

{{% notice note %}}
At the moment, the parser page cannot handle multiline events. You will have to rely on external data-shippers to handle this,
e.g. [filebeat]({{< ref "filebeat.md" >}}). Built-in multiline parsing is planned for a future release of Humio - So stay tuned!
{{% /notice %}}


## Adding Tags

Humio saves data in Data Sources. You can provide a set of [tags]({{< ref "tags.md" >}}) to specify which Data Source the data is saved in.
Using tags can significantly speed up searches.

When using a parser, its name is added as the `#type` tag.  
For example using the `accesslog` parser for parsing web server logs will result in events with the tag `#type=accesslog`.   
When creating a parser it is possible to add other tags, by specifying which fields should be treated as tags. This is done by specifying field names as `Tag Fields`.


## Parser Errors

When a parser fails during ingestions Humio automatically adds fields to the event:

 * `@error=true`
 * `@event_parsed=false`
 * `@error_msg`: contains the error


Use can use these fields to refine your parser.
You can search for all events that were not parsed correctly by searching the repository:

``` humio
@event_parsed=false
```

You can extend the query in different ways. For example, you can display a time chart:

``` humio
@event_parsed=false | timechart()
```

Or by group results by error message:

``` humio
@event_parsed=false | groupBy(@error_msg)
```

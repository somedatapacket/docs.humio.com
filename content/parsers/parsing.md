---
title: "Parsing"
---

When sending data to Humio, you can specify a parser.
Humio uses parsers to extract fields and add structure to the data that you send to it.

{{% notice note %}}
When sending data with [Filebeat]({{< relref "filebeat.md" >}})
you specify a parser to parse data.
{{% /notice %}}

Humio comes with a set of [built-in parsers]({{< relref "built_in_parsers.md" >}}) for
common log formats.

If no built-in parsers match your needs, then you can create your own.
This page will guide you through the process of creating a custom
parser.

## List of Parsers

Go to the **Parsers** subpage in your repository to see all the available parsers:

![Parsers List`](/images/parsersx.png)

### Built-in parsers

The first part of the list contains [built-in parsers]({{< relref "built_in_parsers.md" >}}).

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

## Parser Types

Humio supports two types of parsers:

* [JSON Parsers]({{< relref "#json-parser" >}})
* [Regular expressions parsers]({{< relref "#regular-expression-parser" >}})

At the top of the page, select the type of parser you want to create.

### JSON Parser {#json-parser}

Humio has a special class of parser, called JSON parsers. Since
JSON data is already structured, you do not need to extract fields manually.
Humio turns JSON properties into fields as shown below:

```json
{
  "ts": "2017-02-22T11:04:17.000+01:00",  
  "loglevel": "INFO",  
  "thread": "TimerThread",  
  "timing": {  
    "name": "service1",
    "time": 42
  }
}
```

Resulting Fields:

| field      | value                           |
|------------|---------------------------------|
|ts          | "2017-02-22T11:04:17.000+01:00" |
|loglevel    | "INFO"                          |
|thread      | "TimerThread"                   |
|timing.name | "service1"                      |
|timing.time | 42                              |


The reason we sometimes need to define custom JSON parsers is to parse the timestamp.
The build-in JSON parser ([json]({{< relref "built_in_parsers.md#json" >}})) expects
a field called `@timestamp`, but this will not always exist for arbitrary JSON logs.

When defining a JSON parser you specify which JSON property should be used as timestamp,
and how that field should be parsed.

You can find out how to parse timestamps at the [Parsing Timestamps section below]({{< relref "#parsing-timestamps" >}}).


{{% notice tip %}}
***Testing***  
You can test the parser on the **Parser** page by adding some test data. This offers an interactive way to refine the parser.
See the section on [Testing the Parser]({{< relref "#testing-parsers" >}}) section below.
{{% /notice %}}


### Regular Expression Parsers {#regular-expression-parser}

Regular expression (regex) parsers lets you parse incoming data using a
regular expression. Humio extracts fields using _named capture groups_ -
feature of regular expressions that allows you to name sub-matches, e.g:

```regex
(?<firstname>\S+)\s(?<lastname>\S+)
```

This defines a parser that expects input to contain names, first and last. It then extracts
the first and last names into two fields `firstname` and `lastname`. The `\S` of course means
any character that is not a whitespace and `\s` is a whitespace character.

When creating a regex parser you always have to extract a field called `@timestamp`.
Here is an example:

```regex
(?<@timestamp>\S+\s\S+)\s(?<rest>.*)
```

This creates two fields `@timestamp` and `rest`.

You must also specify a timestamp format. Humio uses this to parse the extracted timestamp.
See the section below on [parsing timestamps]({{< relref "#parsing-timestamps" >}}).

It is a good idea to reference some of the built-in parsers when creating your first regex parser,
to see who they are defined.

{{% notice tip %}}
***Testing***  
You can test the parser on the **Parser** page by adding some test data. This offers an interactive way to refine the parser.
See the section on [Testing the Parser]({{< relref "#testing-parsers" >}}) section below.
{{% /notice %}}

## Parsing Timestamps {#parsing-timestamps}

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

## Key-value parsing
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

## Testing Parsers {#testing-parsers}

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
e.g. [filebeat]({{< relref "filebeat.md" >}}). Built-in multiline parsing is planned for a future release of Humio - So stay tuned!
{{% /notice %}}

## Adding tags

Humio saves data in Data Sources. You can provide a set of [tags]({{< ref "tags.md" >}}) to specify which Data Source the data is saved in.
Using tags can significantly speed up searches.

When using a parser, its name is added as the `#type` tag.  
For example using the `accesslog` parser for parsing web server logs will result in events with the tag `#type=accesslog`.   
When creating a parser it is possible to add other tags, by specifying which fields should be treated as tags. This is done by specifying field names as `Tag Fields`.

## Parsing Error fields
When a parser fails, Humio adds fields to the event:

 * `@error=true`
 * `@event_parsed=false`
 * `@error_msg`: contains the error


### Finding all parsing failures in a repository

You can search for all events that were not parsed correctly:

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

---
title: "Searching"
category_title: "Query Syntax"
weight: 300
---
This section describes the Humio query language.

The Humio query language is the syntax that lets you compose queries to retrieve,
process, and analyze business data in your system.

Before reading this section, we recommend that you read the
[tutorial]({{< ref "tutorial/_index.md" >}}). The tutorial introduces you to queries
in Humio, and lets you try out some sample queries that demonstrate the basic principles.


## Principles

We built the Humio query language around a 'chain' of data processing commands
linked together. Each expression passes its result to the next expression in sequence.
In this way, you can create complex queries by combining query expressions together.

This architecture is similar to the idea of [command
pipes](https://en.wikipedia.org/wiki/Pipeline_(Unix)) in Unix and Linux shells.
This idea has proven to be a powerful and flexible mechanism for advanced data analysis.


## Basic Query Components

The basic model of a query in Humio is that data arrives at the
left of the query, and the result comes out at the right of the query.
When Humio executes the query, it passes the data through from the left to the right.

As the data passes through the query, Humio filters, transforms, and aggregates
it according to the query expressions.

For example, the following query has these components:

* Two tag filters
* One filter expression
* Two aggregate expressions

```humio
 #host=github #parser=json | repo.name=docker/* | groupBy(repo.name, function=count()) | sort()

|--------------------------|--------------------|-----------------------------------------------|
        Tag Filters        |       Filter       |                  Aggregates                   |
```

{{% notice tip %}}
To chain query expressions, use the 'pipe' character, `|`, between each of the query expressions.  
This causes Humio to pass the output from one expression into the next expression.
{{% /notice %}}

## Tag filters

Tag filters always start with a `#` character. They behave in the same way as
regular [attribute filters]({{< ref "#attribute-filters" >}}).

In the example shown in the previous section ([Basic Query Components]({{< ref "#basic-query-components" >}})),
we have separated the tag filters from the rest of the query by a pipe character `|`.

We recommend that you include the pipe character before tag filters in your
queries to improve the readability of your queries.

However, these pipe characters are not mandatory. The Humio query engine can
recognize tag filters when they are at the front of the query, and use this
information to narrow  down the number of data sources to search.
This feature decreases query time.

See the [tags documentation]({{< ref "tags.md" >}}) for more on tags.


## @rawstring filters

The most basic query in Humio is to search for a particular string in the `@rawstring` attribute of events.
See the [events documentation]({{< ref "events.md#rawstring" >}}) for more details on `@rawstring`.

{{% notice note %}}
You can perform more complex regular expression searches on the `@rawstring`
attribute of an event by using the {{% function "regex" %}} function.
{{% /notice %}}


### Examples

| Query | Description |
|-------|-------------|
| {{< query >}}foo{{< /query >}} | Find all events matching "foo" in the `@rawstring` attribute of the events |
| {{< query >}}"foo bar"{{< /query >}} | Use quotes if the search string contains white spaces or special characters, or is a keyword. |
| {{< query >}}"msg: \"welcome\""{{< /query >}} | You can include quotes in the search string by escaping them with backslashes. |

You can also use a regular expression to match rawstrings.  To do this, just
write the regex.

| Query | Description |
|-------|-------------|
| {{< query >}}/foo/{{< /query >}} | Find all events matching "foo" in the `@rawstring` attribute of the events |
| {{< query >}}/foo/i{{< /query >}} | Find all events matching "foo" in the `@rawstring`, ignoring case |


## Attribute Filters

Besides the `@rawstring`, you can also query event attributes, both as
text and as numbers.


### Examples

#### Text fields

| Query | Description |
|-------|-------------|
|{{< query >}}url = *login*{{< /query >}} | The `url` field contains `login`. You can use `*` as a wild card. |
|{{< query >}}user = *Turing{{< /query >}} | The `user` field ends with `Turing`.
|{{< query >}}user = "Alan Turing"{{< /query >}} | The `user` field equals `Alan Turing`.
|{{< query >}}user != "Alan Turing"{{< /query >}} | The `user` field does not equal `Alan Turing`.
|{{< query >}}url != *login*{{< /query >}} | The `url` field does not contain `login`.
|{{< query >}}user = *{{< /query >}} | Match events that have the field `user`.
|{{< query >}}user != *{{< /query >}} | Match events that do not have the field `user`.
|{{< query >}}name = ""{{< /query >}} | Match events that have a field called `name` but with the empty string as value.
|{{< query >}}user="Alan Turing"{{< /query >}} | You do not need to put spaces around operators (for example, `=` or `!=`).

#### Regex filters

In addition to globbing (`*` appearing in match strings) you can match fields using regular expressions.

| Query | Description |
|-------|-------------|
|{{< query >}}url = /login/{{< /query >}} | The `url` field contains `login`.
|{{< query >}}user = /Turing$/{{< /query >}} | The `user` field ends with `Turing`.
|{{< query >}}loglevel = /error/i{{< /query >}} | The `loglevel` field matches `error` case insensitively, i.e. it could be `Error`, `ERROR` or `error`.


#### Comparison operators on numbers

| Query | Description |
|-------|-------------|
| {{< query >}}statuscode < 400{{< /query >}} | Less than|
| {{< query >}}statuscode <= 400{{< /query >}} | Less than or equal to |
| {{< query >}}statuscode = 400{{< /query >}} | Equal to |
| {{< query >}}statuscode != 400{{< /query >}} | Not equal to |
| {{< query >}}statuscode >= 400{{< /query >}} | Greater than or equal to|
| {{< query >}}statuscode > 400{{< /query >}} | Greater than|
| {{< query >}}400 = statuscode{{< /query >}} | (!) The attribute '400' is equal to `statuscode`.|
| {{< query >}}400 > statuscode{{< /query >}} | This comparison generates an error. You can only perform a comparison between numbers. In this example, `statuscode` is not a number, and `400` is the name of an attribute.|

{{% notice note %}}
The left-hand-side of the operator is interpreted an attribute name.
If you write `200 = statuscode`, Humio tries to find an attribute
named `200` and test if its value is `"statuscode"`.
{{% /notice %}}

{{% notice warning %}}
If the specified attribute is not present in an event, then the comparison always fails.
You can use this behavior to match events that do not have a given field,
using either `not (foo=*)` or the equivalent `foo!=*` to find events
that do not have the attribute `foo`.
{{% /notice %}}

<!-- TODO: State explicitly which comparison operators will yield positive for missing attributes, and which ones won't. Especially: "!=" -->

## Combining Filter Expressions

You can combine filters using the `and`, `or`, `not` Boolean operators,
and group them with parentheses.


### Examples

| Query                                            | Description |
|--------------------------------------------------|-------------|
| {{< query >}}foo and user=bar{{< /query >}}      | Match events with `foo` in the`@rawstring` attribute and a `user` attribute matching `bar`. |
| {{< query >}}foo bar{{< /query >}}               | Since the `and` operator is implicit, you do not need to include it in this simple type of query.
| {{< query >}}statuscode=404 and (method=GET or method=POST){{< /query >}} | Match events with `404` in their `statuscode` attribute, and *either* `GET` or `POST` in their `method` attribute. |
| {{< query >}}foo not bar{{< /query >}}           | This query is equivalent to the query {{< query >}}foo and (not bar){{< /query >}}.|
| {{< query >}}not foo bar{{< /query >}}           | This query is equivalent to the query {{< query >}}(not foo) and bar{{< /query >}}. This is because the `not` operator has a higher priority than `and` and `or`.|
| {{< query >}}foo and not bar or baz{{< /query >}}| This query is equivalent to the query {{< query >}}foo and ((not bar) or baz){{< /query >}}. This is because Humio has a defined order of precedence for operators. It evaluates operators from the left to the right. |
| {{< query >}}foo or not bar and baz{{< /query >}}| This query is equivalent to the query {{< query >}}foo or ((not bar) and baz){{< /query >}}. This is because Humio has a defined order of precedence for operators. It evaluates operators from the left to the right. |
| {{< query >}}foo not statuscode=200{{< /query >}}| This query is equivalent to the query {{< query >}}foo and statuscode!=200{{< /query >}}. |


## Composing queries

You can build advanced queries can by combining small queries using pipes.

Together, these small queries form a query pipeline.

Humio introduces events into each query pipeline, and filters, transforms, and aggregates the data as appropriate.

The following example shows a typical query pipeline:

| Query                                         | Description                                                          |
|-----------------------------------------------|----------------------------------------------------------------------|
| {{< query >}}statuscode != 200 | count(){{< /query >}} | Count the number of `statuscode` values that are not equal to `200`. |

<!-- ^^ Workaround to get pipe-in-code-in-table. -->

{{% notice note %}}
Queries can be built by combining filters and functions.
You can find out more about [Query Functions]({{< relref "query-functions/_index.md" >}}).
{{% /notice %}}


## Extracting new attributes

You can extract new attributes from your text data using regular expressions
and then test their values. This lets you access data that Humio did not parse
when it indexed the data.

For example, if your log entries contain text such as
`"... disk_free=2000 ..."`, then you can use a query like the following
to find the entries that have less than 1000 free disk space:

```humio
regex("disk_free=(?<space>[0-9]+)") | space < 1000
```

{{% notice tip %}}
Since regular expressions do need some computing power, it is best to do as much
simple filtering as possible earlier in the query chain before applying the regex function.
{{% /notice %}}

You can also use regex expressions to extract new fields. So the above could also
be written

```humio
/disk_free=(?<space>[0-9]+)/ | space < 1000
```

In order to use field-extraction this way, the regex expression must be
a "top-level" expression, i.e. `|` between bars `|` i.e., the following doesn't work:

```humio
type=FOO or /disk_free=(?<space>[0-9]+)/ | space < 1000
```

## Assigning new attributes from functions

Attributes can also get a value as the output of many functions.
Most functions set their result in a field that has the function name prefixed
with a '\_' as name by default. E.g. the "count" function outputs to `_count` by default.
The name of the target field can be set using the parameter `as` on most functions.
E.g. {{< query >}}count(as=cnt){{< /query >}} assigns the result of the count to the field named `cnt`.


### Eval Syntax

The function {{% function "eval" %}} can assign fields
while doing numeric computations on the input.

The `:=` syntax is short for eval. Use `|` between assignments.

```humio
... | foo := a + b | bar := a / b |  ...
```

is short for

```humio
... | eval(foo = a + b) | eval(bar = a / b) | ...
```

When what's on the right hand side of the assignment is a function call, the
assignment is rewritten to specify the `as=` argument which, by convention, is
the output attribute name i.e.,

```humio
... | foo := min(x) | bar := max(x) |  ...
```

is short for

```humio
... | min(x, as=foo) | max(x, as=bar) | ...
```

Similarly, you can use {{< query >}}attr =~ fun(){{< /query >}} to designate the {{< query >}}field=attr{{< /query >}} argument.
This lets you write:

```humio
... | ip_addr =~ cidr("127.0.0.1/24") | ...
```

rather than

```humio
... | cidr("127.0.0.1/24", field=ip_addr) | ...
```

This also works well with e.g. {{< function "regex" >}} and {{< function "replace" >}}.
It's just a shorthand but very convenient.

### Back-ticks

Back-ticks work in {{< function "eval" >}} and the `:=` shorthand for eval only and provides one
level of indirection of the name of the field.
The assignment happens to the field with the name that is the value of the back-ticked field.

An example on events with the following fields, which is e.g. the outcome of {{< query >}}top(key){{< /query >}}.:

```javascript
{ key: "foo", value: "2" }
{ key: "bar", value: "3" }
...
```

Using

```humio
... | `key`:=value | ...
```

will get you events with

```javascript
{ key: "foo", value: "2", foo: "2" }
{ key: "bar", value: "3", bar: "3" }
...
```

Then you can time chart them by doing

```humio
timechart( function={ top(key) | `key` := _count } )
```

<!-- TODO:  But maybe we should have an alternative function to do the transpose, such as `transpose([key,value])` which takes a `Seq[{ key=k, value=v }]` and turns it onto a single event, with `{ k1=v1, k2=v2, ... }`. -->


## Conditionals

There is no "if-then-else" syntax in humio, since the _streaming_
style is not well-suited for procedural-style conditions.

But there are a couple of ways to do conditional evaluation, they are called

- [Case Statements]({{< relref "#case" >}})
- [Side Effects]({{< relref "#side-effects" >}})

### Case Statements

`case` describes alternative flows (as in `case` or `cond` in other languages).
You write a sequence (`;` separated) of pipe lines, and the first of these to
emit a value ends the selection.  

You can add {{< query >}}case { ... ; * }{{< /query >}} to let all events through.

In effect, it is kind of an if-then-if-then-else construct for events streams.
An alternative cannot be syntactically empty, you must put in an explicit `*` to match all.

An example: We have logs from multiple sources that all have a "time" field,
and we want to get percentiles of the time fields, but one for each kind of source.

To distinguish the lines, we need to match a text, then set a field ("type")
that we can then group by.

```humio
time=*
| case { "client-side"     | type := "client";
         "frontend-server" | type := "frontend";
         Database          | type := "db" }
| groupBy(type, function=percentile(time)))
```


### Settings Field Default {#side-effects}
<!-- TODO(Thomas) I think this entire section should be left our. It is an advanced technique, that is more of a work-around. -->
If all you want to do is set a default value for a field if the field is not present,
you don't need case-statements.
You can simply use the fact that a function that can assign an attribute
(such as `eval`) only assigns the field if can resolve a value for all fields involved.
In other words: if you do {{< query >}}eval(newField=nonExistingField*2){{< /query >}}
and `nonExistingField` does not exist, nothing happens e.i. `newField` is not assigned.

Using this we can set a default value if some other value is not present.
Here we set the field `foo` to the value `missing` if there is no `bar` field,
and otherwise set `foo` to the value of the `bar` field.

```humio
... | eval(foo="missing") | eval(foo=bar) | ..."
```

The downside is that it is not actually the field `foo` that gets the default,
but rather the new field `bar`, which we can use in its place.

## Composite Function Calls

See [Query Functions]({{< relref "functions/_index.md" >}}).

Whenever a function accepts a function as an argument, there are some
special rules.  For all variations of {{% function "groupBy" %}}
({{% function "bucket" %}} and {{% function "timechart" %}}), that
take a `function=` argument, you can also use a composite function.
Composite functions take the form `{ f1(..) | f2(..) }` which works
like the composition of `f1` and `f2`.  For example, you can do:

```humio
groupBy(type, function={ avgFoo := avg(foo) | outFoo := round(avgFoo) })
```

You can also use filters inside such composite function calls, but not
macros.


## Using Saved Queries as macros/functions

If you have stored a query as a 'saved query', then it can be used as a top-level
element of another query, sort of like a function call.

To use a saved query this way, you invoke it using the syntax `$"name of saved query"()`
or, if the name of the saved query is an identifier, you can use `$nameOfSavedQuery()`,
plain and simple.  A typical use for this is to define a filter or
extraction ruleset, that you can use as a prefix of another query.

Currently macros do not support parameters, though this will be part of a future
release - that is why we put parentheses at the end.

### Example

```humio
$"saved query name"() | $filterOutFalsePositive() | ...
```

<!---
Saved queries can also have arguments.  These are identified as
`?{arg="foo"}` which gives the query parameter `arg` the default value `foo`.
Arguments can be used anywhere a string, number or identifier is allowed.

Now, when you invoke a saved query as a macro, you can pass new values for the
arguments.  You do this like this:

```
$"saved query name"(arg1=value, arg2=value, ...) | ...
```

or the more programming-language like:

```
$SavedQueryName(arg1=value, arg2=value, ...) | ...
```
-->

## Comments

Queries can have comments.  This is useful for long multi-line queries,
to add some description:

```humio
#type=accesslog // choose the type
| top(url)  // count urls and choose the most frequently used
```

The Humio query language supports `// single line` and `/* multi line */`
comments just like Java or C++.

---
title: "Language Syntax"
weight: 300
menuTOC:
  - "#intro": "Pipeline"
  - "#grepping": "Free-Text Filters"
  - "#field-filters": "Field Filters"
  - "#adding-fields": "Adding New Fields"
  - "#assignment-operator": "Assignment Operator (:=)"
  - "#field-operator": "Field Operator (=~)"
  - "#eval": "Eval"
  - "#logical-operators": "Logical Operators (and, or, not)"
  - "#conditionals": "Conditionals (case)"
  - "#composite-function-calls": "Composite Function Calls"
  - "#user-functions": "User Functions"
  - "#comments": "Comments"
---

The Humio Query Language is the syntax that lets you compose queries to retrieve,
process, and analyze data in Humio.

Before reading this section, we recommend that you read the
[tutorial]({{< ref "tutorial/_index.md" >}}). The tutorial introduces you to queries
in Humio, and lets you try out sample queries that demonstrate the basic principles.


## Principles {#intro}

The Query Language is built around a 'chain' of data processing commands
linked together. Each expression passes its result to the next expression in the sequence.
That way you can create complex queries by combining query expressions.

This architecture is similar to the idea of [command pipes](https://en.wikipedia.org/wiki/Pipeline_(Unix))
in Unix and Linux shells.
This idea has proven to be a powerful and flexible mechanism for advanced data analysis.


## The structure of a query {#pipeline}

The basic model of a query is that data arrives at the
left of the query, and the result comes out at the right of the query.
When Humio executes the query, it passes the data through from the left to the right.

<figure>
{{<mermaid align="center">}}
graph LR;
    A{Repository}   -->|Events| B
    B[Tag Filters]  -->|Events| C
    C[Filters]      -->|Events| D
    D[Aggregates]   -->|Rows| E
    E{Final Result}
{{< /mermaid >}}
<figcaption>Events flow through the query pipeline, from the repository to the left.
Events are filtered or transformed as it passes through filters, and aggregates. After an aggregation the data is usually no longer events, but one or more simple rows containing the results.</figcaption>
</figure>

As the data passes through the query, Humio filters, transforms, and aggregates
it according to the query expressions.

Expressions are chained using the 'pipe' operator `|`.  
This causes Humio to pass the output from one expression (left) into the next
expression (right) as input.

For example, the following query has these components:

* Two tag filters
* One filter expression
* Two aggregate expressions

```humio
#host=github #parser=json | // <-- Tag Filters
repo.name=docker/* | // <-- Filter Expression
groupBy(repo.name, function=count()) | sort() // <-- Aggregates
```

## Free-Text Filters (aka grepping) {#grepping}

The most basic query in Humio is to search for a particular string in the `@rawstring` field of events.
See the [events documentation]({{< ref "events.md#rawstring" >}}) for more details on `@rawstring`.

{{% notice note %}}
You can perform more complex regular expression searches on the `@rawstring`
field of an event by using the {{% function "regex" %}} function.
{{% /notice %}}


### Examples

| Query | Description |
|-------|-------------|
| {{< query >}}foo{{< /query >}} | Find all events matching "foo" in the `@rawstring` field of the events |
| {{< query >}}"foo bar"{{< /query >}} | Use quotes if the search string contains white spaces or special characters, or is a keyword. |
| {{< query >}}"msg: \"welcome\""{{< /query >}} | You can include quotes in the search string by escaping them with backslashes. |

You can also use a regular expression to match rawstrings.  To do this, just
write the regex.

| Query | Description |
|-------|-------------|
| {{< query >}}/foo/{{< /query >}} | Find all events matching "foo" in the `@rawstring` field of the events |
| {{< query >}}/foo/i{{< /query >}} | Find all events matching "foo" in the `@rawstring`, ignoring case |


## Field Filters

Besides the `@rawstring`, you can also query event fields, both as
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
|{{< query >}}/user with id (?&lt;id&gt;\S+) logged in/ | top(id){{< /query >}} | The user id is extracted into a field named `id` at search time. The `id` is then used in the top function to find the users that logged in the most. It is possible to extract fields in regular expressions using named groups. See [Regex field extraction]({{< ref "#extracting-fields" >}}) for details.

#### Comparison operators on numbers

| Query | Description |
|-------|-------------|
| {{< query >}}statuscode < 400{{< /query >}} | Less than|
| {{< query >}}statuscode <= 400{{< /query >}} | Less than or equal to |
| {{< query >}}statuscode = 400{{< /query >}} | Equal to |
| {{< query >}}statuscode != 400{{< /query >}} | Not equal to |
| {{< query >}}statuscode >= 400{{< /query >}} | Greater than or equal to|
| {{< query >}}statuscode > 400{{< /query >}} | Greater than|
| {{< query >}}400 = statuscode{{< /query >}} | (!) The field '400' is equal to `statuscode`.|
| {{< query >}}400 > statuscode{{< /query >}} | This comparison generates an error. You can only perform a comparison between numbers. In this example, `statuscode` is not a number, and `400` is the name of an field.|

{{% notice note %}}
The left-hand-side of the operator is interpreted an field name.
If you write `200 = statuscode`, Humio tries to find an field
named `200` and test if its value is `"statuscode"`.
{{% /notice %}}

{{% notice warning %}}
If the specified field is not present in an event, then the comparison always fails.
You can use this behavior to match events that do not have a given field,
using either `not (foo=*)` or the equivalent `foo!=*` to find events
that do not have the field `foo`.
{{% /notice %}}

<!-- TODO: State explicitly which comparison operators will yield positive for missing fields, and which ones won't. Especially: "!=" -->

### Tag Filters {#tag-filters}

Tag filters are a special kind of field filter. They behave in the same way as
regular [filters]({{< ref "#field-filters" >}}).

In the example shown in the previous section ([Basic Query Components]({{< ref "#pipeline" >}})),
we have separated the tag filters from the rest of the query by a pipe character `|`.

We recommend that you include the pipe character before tag filters in your
queries to improve the readability of your queries.

However, these pipe characters are not mandatory. The Humio query engine can
recognize tag filters, and use this
information to narrow  down the number of data sources to search.
This feature decreases query time.

See the [tags documentation]({{< ref "tags.md" >}}) for more on tags.

## Logical Operators: `and`, `or`, `not`, and `!` {#logical-operators}

You can combine filters using the `and`, `or`, `not` Boolean operators,
and group them with parentheses.  `!` can also be used as an alternative to unary `not`.

### Examples

| Query                                            | Description |
|--------------------------------------------------|-------------|
| {{< query >}}foo and user=bar{{< /query >}}      | Match events with `foo` in the`@rawstring` field and a `user` field matching `bar`. |
| {{< query >}}foo bar{{< /query >}}               | Since the `and` operator is implicit, you do not need to include it in this simple type of query.
| {{< query >}}statuscode=404 and (method=GET or method=POST){{< /query >}} | Match events with `404` in their `statuscode` field, and *either* `GET` or `POST` in their `method` field. |
| {{< query >}}foo not bar{{< /query >}}           | This query is equivalent to the query {{< query >}}foo and (not bar){{< /query >}}.|
| {{< query >}}!bar{{< /query >}}           | This query is equivalent to the query {{< query >}}not bar{{< /query >}}.|
| {{< query >}}not foo bar{{< /query >}}           | This query is equivalent to the query {{< query >}}(not foo) and bar{{< /query >}}. This is because the `not` operator has a higher priority than `and` and `or`.|
| {{< query >}}foo and not bar or baz{{< /query >}}| This query is equivalent to the query {{< query >}}foo and ((not bar) or baz){{< /query >}}. This is because Humio has a defined order of precedence for operators. It evaluates operators from the left to the right. |
| {{< query >}}foo or not bar and baz{{< /query >}}| This query is equivalent to the query {{< query >}}foo or ((not bar) and baz){{< /query >}}. This is because Humio has a defined order of precedence for operators. It evaluates operators from the left to the right. |
| {{< query >}}foo not statuscode=200{{< /query >}}| This query is equivalent to the query {{< query >}}foo and statuscode!=200{{< /query >}}. |

## Negating the result of filter functions {#negate-filter-function}

The `not` and `!` operators can also be used to negate filter-function expressions, which is syntactically more clean than passing in an explicit `negate=true` argument.  This examples of this are:

```humio
... | !cidr(ip, subnet="127.0.0/16") | ...
... | !in(field, values=[a, b, c]) | ...
... | !regex("xxx") | ...
```

## Adding new fields {#adding-fields}

New fields can be created in two ways:

- [Regex field extraction]({{< ref "#extracting-fields" >}})
- [Functions that add fields]({{< ref "#fields-from-functions" >}})

### RegEx Field Extraction {#extracting-fields}

You can extract new fields from your text data using regular expressions
and then test their values. This lets you access data that Humio did not parse
when it indexed the data.

For example, if your log entries contain text such as
{{< query >}}... disk_free=2000 ...{{< /query >}}, then you can use a query like the following
to find the entries that have less than 1000 free disk space:

```humio
regex("disk_free=(?<space>[0-9]+)") | space < 1000
```

Named capturing groups are used to extract fields in regular expressions. The field `space` is extracted and is then available after the regex function.  
The same can be written using a regex literal:

```humio
/disk_free=(?<space>[0-9]+)/ | space < 1000
```

**WARNING**  
In order to use field-extraction this way, the regex must be
a top-level expression, i.e. `|` between bars `|` i.e., the following doesn't work:

```humio
// DON'T DO THIS - THIS DOES NOT WORK
type=FOO or /disk_free=(?<space>[0-9]+)/ | space < 1000
```

{{% notice tip %}}
Since regular expressions do need some computing power, it is best to do as much
simple filtering as possible earlier in the query chain before applying the regex function.
{{% /notice %}}

### Fields produced by functions (`as`-parameters) {#fields-from-functions}

Fields can also be added by functions.
Most functions set their result in a field that has the function name prefixed
with a '\_' by default. For example the {{% function "count" %}} puts its result in a field `_count`.

Most functions that produce fields have a parameter called `as`. By setting this parameter you
can specify the name of the output field, for example:

```humio
count(as=cnt)
```

Assigns the result of the {{% function "count" %}} to the field named `cnt` (instead of the default `_count`).

See also the [assignment operator]({{< ref "#assignment-operator" >}}) for shorthand syntax for assigning results to a field.

## Eval Syntax {#eval}

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

### Dynamic field names based on input

If you want the field produced by an eval to be named based on the input you can
use the back-tick syntax. This work for both {{< function "eval" >}} and the `:=` shorthand.
This will produce a field named after the value of the field in back-ticks.

An example on events with the following fields, which is e.g. the outcome of {{< query >}}top(key){{< /query >}}.:

```javascript
{ key: "foo", value: "2" }
{ key: "bar", value: "3" }
...
```

Using

```humio
... | `key` := value * 2 | ...
```

will get you events with

```javascript
{ key: "foo", value: "2", foo: "4" }
{ key: "bar", value: "3", bar: "6" }
...
```

Then you can time chart them by doing:

```humio
timechart( function={ top(key) | `key` := _count } )
```

_This last example uses the a [composite function call]({{< ref "#composite-function-calls" >}}) for the `function=` argument_.

<!-- TODO:  But maybe we should have an alternative function to do the transpose, such as `transpose([key,value])` which takes a `Seq[{ key=k, value=v }]` and turns it onto a single event, with `{ k1=v1, k2=v2, ... }`. -->

## The assignment operator {#assignment-operator}

You can use the operator `:=` with functions that take an `as`-parameter,
When what's on the right hand side of the assignment is a function call, the
assignment is rewritten to specify the `as=` argument which, by convention, is
the output field name i.e.,

```humio
... | foo := min(x) | bar := max(x) |  ...
```

is short for

```humio
... | min(x, as=foo) | max(x, as=bar) | ...
```

## The field operator {#field-operator}

You can use {{< query >}}attr =~ fun(){{< /query >}} with any function that has
a parameter named `field`. It designates the {{< query >}}field=attr{{< /query >}} argument
and lets you write:

```humio
... | ip_addr =~ cidr(subnet="127.0.0.1/24") | ...
```

rather than

```humio
... | cidr(subnet="127.0.0.1/24", field=ip_addr) | ...
```

This also works well with e.g. {{< function "regex" >}} and {{< function "replace" >}}.
It's just a shorthand but very convenient.


## Conditionals

There is no "if-then-else" syntax in humio, since the _streaming_
style is not well-suited for procedural-style conditions.

But there are a couple of ways to do conditional evaluation, they are called

- [Case Statements]({{< relref "#case" >}})
- [Side Effects]({{< relref "#side-effects" >}})

### Case Statements {#case}

Using case-statements you can describe alternative flows in your queries.
It is similar to `case` or `cond` you might know from many other functional programming languages.
It essentially allows you to write `if-then-else` constructs that work on for events streams.

The syntax looks like this:

```humio
case {
  expression | expression | ...;
  expression | expression | ...;
  expression | expression | ...;
  * | expression | ...
}
```

You write a sequence of pipeline clauses separated by semicolon (`;`). Humio will apply each clause
from top to bottom until one emits a value (i.e. matches the input).

You can add wildcard clause {{< query >}}case { ... ; * }{{< /query >}} which
matches all event as the "default case", essentially the `else` part of an if-statement.
If you don't add a wildcard clause any events that don't match any of the explicit clauses will
be dropped. You cannot use the empty clause - you must explicit write `*` to match all.

#### Example

Let's say we have logs from multiple sources that all have a field named `time`,
and we want to get percentiles of the time fields, but one for each kind of source.

First we try to match some text that distinguishes the different types of line.
Then we can create a new field `type` and assign a value that we can use to group by:

```humio
time=*
| case { "client-side"     | type := "client";
         "frontend-server" | ip != 192.168.1.1 | type := "frontend";
         Database          | type := "db" }
| groupBy(type, function=percentile(time)))
```


### Setting a field's default value {#side-effects}

You can use the function {{< function "default" >}} to set the value of a missing
or empty field.

## Composite Function Calls {#composite-function-calls}

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


## User Functions {#user-functions}

If you have stored a query as a 'saved query', then it can be used as a top-level
element of another query, sort of like a function call.

To use a saved query this way you invoke it using the syntax `$"$NAME_OF_SAVED_QUERY"()`
or, if the name does not contain whitespace or special characters you can use `$nameOfSavedQuery()`
without quotes.  A typical use for this is to define a filter or
extraction ruleset, that you can use as a prefix of another query.

Currently user functions do not support parameters, though this will be part of a future
release - that is why we put parentheses at the end.

### Example

```humio
$"My Saved Query"() | $filterOutFalsePositive() | ...
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

## Links

When showing search results in a table it is possible to create a link that is clickable.
If the value of a field looks like a link, the UI will make it clickable.
Links can be constructed using the search language. The {{% function "format" %}} function can be handy for this.

``` humio
$extractRepo() | top(repo) | format("https://myhumio/%s", field=repo, as=link)
```

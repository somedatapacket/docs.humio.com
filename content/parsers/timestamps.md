---
title: Timestamps
---

In Humio the time at which an event occurred is stored in the field `@timestamp`.
Everything (be it logs or metrics) must have a `@timestamp` and if one is not assigned
by the parser Humio will automatically assign the current system time to `@timestamp`.

## Parsing Timestamps

The most important job a parser has to do is to assign timestamps to events.
The `@timestamp` field must be formatted as Unix Time in milliseconds, e.g. `1542400149000` for
`11/16/2018 @ 8:29pm (UTC)`.

The problem is that most incoming data will contain the timestamp in some other more human-readable format, e.g. ISO 8601.

That is why most parsers will take a formatted timestamp from the input event
and convert it to Unix Time using the {{< function "parseTimestamp" >}} function.

Here is an example parser for the following JSON data:

```json
{ "ts": "11/16/2018 @ 8:29pm (UTC)", "eventType": "login", "username": "monkey" }
```

```humio
parseJson() | parseTimestamp("MM/dd/yyyy @ h:mma (z)", field=ts)
```

Getting the timestamp format exactly right is important and can be difficult.
Look at [Java's DateTimeFormatter documentation](https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html)
for details on how to define the timestamp format.

The default timestamp format used by `parseTimestamp` is [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601),
i.e. `yyyy-MM-dd'T'HH:mm:ss[.SSS]XXX`.

## Timezones

Since Humio stores timestamps in Unix Time the timezone present on the
input (if any) is stored in a separate field called `@timezone`.

In most cases this field will have the value `Z` (UTC).

### Dealing with missing timezone in `parseTimestamp`

The {{% function "parseTimestamp" %}} function requires that you specify
which timezone the timestamp string is for.
If there is no timezone specified in the input, you will have to provide a
hardcoded timezone.

You can do this by specifying the `timezone` parameter to the {{% function "parseTimestamp" %}}
function. For example given the input event:

```json
{ "ts": "2018/11/01 14:31:10", "server": "web01", "message": "Out of memory" }
```

Notice that there is no zone information in the timestamp. We can set it explicitly:

```humio
parseJson() | parseTimestamp("yyyy/MM/dd HH:mm:ss", timezone="Europe/Paris", field=ts)
```

See the docs for {{% function "parseTimestamp" %}} for more options for setting
the timezone.

---
title: Parser Errors
---

When a parser fails to parse incoming input Humio automatically
adds the following fields to the event and stores:

 * `@error=true`
 * `@event_parsed=false`
 * `@error_msg`: contains the error message

You can search for these fields to determine the what happened and update the
parser's script accordingly. When you find an error it can be a good idea to
add the `@rawstring` of any events that fail to parse as a test case for your parser.

## Finding errors in your repository's parsers

You can search for all events that were not parsed correctly by searching the repository:

```humio
@error=*
```

You can extend the query in different ways. For example, you can display a timechart:

```humio
@error=* | timechart()
```

or group results by error message:

```humio
@error=* | groupBy(@error_msg)
```

## FAQ: How do I re-parse an event in Humio

There is no way for Humio to re-parse data once it is stored. Even if there is
an error on the event. You will have to resend the event through the ingest API.

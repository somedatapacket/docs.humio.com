---
title: "Blacklisting Queries"
weight: 30
aliases: ["configuration/blacklist", "/administration/blacklisting-queries"]
---

When necessary, Humio can be configured to prevent matching queries from executing.
There are many scenarios where one might consider blacklisting a query or a pattern that
matches many queries:
 * A query pattern is known to use a large proportion of the system resources.
 * A query is known to be used for malicious purposes (e.g. searching for secure secrets)
 * A log line contains information that should never be searched for.

The process of blacklisting a query is simple, here's how you do it.

## Blacklisting

First and foremost, to blacklist a query you must have `root` authorization.  You will find
the Query Blacklist section in the Administration page.  There you can add a pattern that is
either an exact match for the queries you'd like to match or a regular expression.  Simply
choose one of those options, and add your pattern text.  To restrict the blacklisted pattern
to a specific repository simply add it in the "Restrict to Repo/View" field.  Then simply
click "Create".

Queries currently running that match the new pattern are stopped immediately and prevented
from running until this blacklist entity is removed by an administrator.

To remove the blacklisted query pattern simply select it and click "Unblock".

## How a User Will Know Their Query is Blacklisted

Queries are the primary interface to data in Humio and so it is important that users are not
confused when a query they submit happens to be blacklisted.  Say for instance that we added
the pattern `/admin-[0-9]?/` to the global blacklist and then a user submits a query for
`admin-1`.  We present a very detailed message in place of event data:

```
Failed to execute the query
There was an error while trying to start the query:

The query has been blacklisted in Humio by an administrator. This is probably due to the query being very resource demanding. Consider rewriting the query to perform better.  The matched blacklist entry is: /admin-[0-9]/
```

This helps the user know what has happened and how future queries my be impacted.  If they
are concerned with this blacklist entry they can pass along the pattern to an administrator
making it easy to locate in the blacklisted queries list.

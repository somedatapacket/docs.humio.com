---
title: Views
weight: 4
---

A view is a special kind of repository, just like repositories they have their
own dashboards, users, etc.

Unlike [repositories]({{< relref "repositories.md" >}}), a view contains no data of its own,
but instead reads data from one or more repositories.

The main function of views is to allow you to search across multiple repositories. But there
are other many powerful use-cases including:

- Access control
- Fine-grained retention strategies
- Redacting sensitive information
- Consolidating different log formats

to name a few, and you can see [some examples later on this page]({{ relref "#examples" }}).

### Searching across multiple repositories

When creating a new view you can connect multiple repos where you want do read from.

#### The `@repo` field

When a view reads data from multiple repositories you can use
the `@repo` meta-field to distinguish where an event comes from.

TIP: You can use `@repo` in conjunction with a `case` statement to modify events
based on which repository they come from.  

#### Filtering {#filtering}

By default views will contain all data from their connected repositories.
This is not always what you want and that is why you can apply a filter to each connection.

A filter will reduce (or transform) the data before it produces the final search result.

A filter is a normal query expression and you can use the same functions that you use
when writing queries. The only thing you can't do is use aggregate functions
like e.g. `groupBy` or `count`.

Here is an example view with two connections with a filter applied to each:

|--------------------|------------------|
| Repository         | Filter           |
|--------------------|------------------|
| accesslogs         | `method=GET`     |
|--------------------|------------------|
| analytics          | `loglevel=INFO`  |
|--------------------|------------------|

now, if you run the following query:

```
ip = 158.191.19.12 | groupBy(url)
```

This would selects all events with the value `158.191.19.12` in the field `ip`
and then groups the joined result each repository by the field `url` .

Under the hood two separate searches are executed:

|--------------------|-------------------------------------------------------|
| Repository         | Executed Query                                        |
|--------------------|-------------------------------------------------------|
| accesslogs         | `method = GET | ip = 158.191.19.12`                   |
|--------------------|-------------------------------------------------------|
| analytics          | `loglevel = INFO | ip = 158.191.19.12`                |
|--------------------|-------------------------------------------------------|

The `groupBy` (the aggregation) is done on the joined result of individual
searches and streamed back to you.

### Example use-cases {#examples}

Here are some examples to give you an idea of what kinds of things you can use
views for.

#### A repo per service

Say you have a micro-service setup and you store all logs from all applications
in a single physical repository, let's call it `acme-project`. It can
become cumbersome to examine logs from each individual service, and their log formats may be very diverse.

First you would have to filter your results down to only include logs from your
target service and write something like:

```
#service=login-service | ...
```

And you would have to do it at the beginning of every single query.
Instead you can create a specialized views for each service:

__Virtual Repo: Nginx Logs__

|--------------------|--------------------|
| Repository         | Filter             |
|--------------------|--------------------|
| `acme-project`     | `#service=nginx`   |
|--------------------|--------------------|

__Virtual Repo: PostgreSQL Logs__

|--------------------|---------------------|
| Repository         | Filter              |
|--------------------|---------------------|
| acme-project       | `#service=postgres` |
|--------------------|---------------------|

__Virtual Repo: iOS App Analytics__

|--------------------|-----------------------------------------|
| Source Repository  | Filter                                  |
|--------------------|-----------------------------------------|
| acme-project       | `#service=app and eventType=analytics`  |
|--------------------|-----------------------------------------|

In this example we create three views that all draw their data from
a single physical repository. If you are using a free cloud account this physical
repository could be you [Sandbox]({{< relref "sandbox.md" >}})

#### Redacting sensitive information {#sensitive}

Your data may contain information that not everyone should have access to.
You can use views to implement security restrictions and censoring.

Let's say your logs contain social security numbers and you don't want your
help desk workers to be able to see these. You can redact them by overriding
the field (e.g. `socialSecurityNo`) that contains the sensitive info in the
filter expression:

|--------------------|----------------------------------------|
| Source Repository  | Filter                                 |
|--------------------|----------------------------------------|
| `hospital-logs`    | `socialSecurityNo := "REDACTED"`       |
|--------------------|----------------------------------------|

#### Restricting access to a subset of a repository {#subset}

Say your system produces logs in several regions, but some of the people who
have search access should only be able to see logs for their respective region.

It is easy to select a subset of the logs by filtering the results before they
reach the user.  in this case limiting access to logs Germany :

|--------------------|----------------------------------------|
| Source Repository  | Filter                                 |
|--------------------|----------------------------------------|
| `website`          | `region = "UK" or region = "DE"`       |
|--------------------|----------------------------------------|
| `db`               | `ip.geo = "UK" or ip.geo = "DE"`       |
|--------------------|----------------------------------------|

In this example we are dealing with two repositories. In


#### Field Aliases

In the [previous example]({{< relref "#subset" >}}) we saw that two repositories
had the same information but in two different fields depending on your parsers and
the logging format. That would mean in order
to search for all events from the "UK"-region we would have to write a query like:

```
region = "UK" or ip.geo = "UK"
```

This is repetitive and clumsy. Instead we can define a new field as part of the
filter expressions:

|--------------------|-----------------------------------------------------|
| Source Repository  | Filter                                              |
|--------------------|-----------------------------------------------------|
| website            | `region = "UK" or region = "DE"`                    |
|--------------------|-----------------------------------------------------|
| db                 | `ip.geo = "UK" or ip.geo = "DE" | region := ip.geo` |
|--------------------|-----------------------------------------------------|

Now you can just write:

```
region = "UK"
```

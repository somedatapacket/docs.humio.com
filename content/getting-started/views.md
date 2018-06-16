---
title: Views
weight: 4
---

In most respects a view is just like an ordinary repository.
They can be searched, they have their own dashboards, users, queries, etc.
But unlike [repositories]({{< relref "repositories.md" >}}), a view contains no data of its own.
Instead views read data from one or more repositories.
In that sense you can think of a view like the view concept from a SQL databases.

A view is defined having a set of connections to repositories
and associated queries that filter or modify the data as it is read.

There are many use-cases for views and you can see
[a list of examples later on this page]({{< relref "#examples" >}}).

### Searching across multiple repositories

The main role of a view is joining data from other repositories
and allowing you to search across their data.

When creating a new view you connect repositories and write a filter query
specifying the subset of the data that should be include:


<figure>
{{<mermaid align="center">}}
graph BT;
    B[Repo 1]   --> A("View 1")
    C[Repo 2]   --> A
    D[Repo 3]   --> A
{{< /mermaid >}}
<figcaption>A view that joins data from three connected physical repositories.</figcaption>
</figure>

When searching, all events include a special `#repo` meta-tag-field with the name
of the repository they where read from.

{{% notice tip %}}
You can use `#repo` in conjunction with a `case`-statement to modify events
based on which repository they come from.  
{{% /notice %}}

#### Filtering {#filtering}

By default views contain all data from their connected repositories.
This is not always what you want and that is why you can apply a filter to each connection.

A filter will reduce (or transform) the data before it produces the final search result.

A filter is a normal query expression and you can use the same functions that you use
when writing queries. The only thing you can't do is use aggregate functions
like {{% function "groupBy" %}} or {{% function "count" %}}.

Here is an example view having two connections with a filter applied to each:

| Repository         | Filter           |
|--------------------|------------------|
| accesslogs         | `method=GET`     |
| analytics          | `loglevel=INFO`  |

now, if you run the following query:

```humio
ip = 158.191.19.12 | groupBy(url)
```

This would selects all events with the value `158.191.19.12` in the field `ip`
and then groups the joined result each repository by the field `url` .

Under the hood two separate searches are executed:

| Repository         | Executed Query                                                  |
|--------------------|-----------------------------------------------------------------|
| accesslogs         | <code>method=GET \| ip = 158.191.19.12</code>                   |
| analytics          | <code>loglevel=INFO \| ip = 158.191.19.12</code>                |

The {{% function "groupBy" %}} (the aggregation) only happens after results of individual
searches are joined. Here is a flow diagram of the process:

<figure>
{{<mermaid align="center">}}
graph LR;
    A[Repo: accesslogs] -->|"method = GET | ip = 158.191.19.12"| B("View")
    C[Repo: analytics] -->|"loglevel = INFO | ip = 158.191.19.12"| B
    B -->|"groupBy(url)"| D{Client}
{{< /mermaid >}}
<figcaption>Query Execution across multiple repositories: Data flows from the
repositories to the view and the
{{% function "groupBy" %}}-aggregation is executed on the joined events.</figcaption>
</figure>

### Example use-cases {#examples}

Views are a powerful tool and you can achieve many things, like:

- Restrict access to a subset of data based on the user
- Fine-grained retention strategies
- Redacting sensitive information
- Consolidating different log formats

Here are some examples of how you can use views to give you an
idea of their power.

#### A repository per service {#per-service}

Say you have a micro-service setup and you store all logs from all applications
in a single repository, let's call it `acme-project`. It can
become cumbersome to examine logs from each individual service, and their log formats may be very diverse.

First you would have to filter your results down to only include logs from your
target service and write something like:

```humio
#service=login-service | ...
```

And you would have to do it at the beginning of every single query.
Instead you can create a specialized view for each service:

__View: Nginx Logs__

| Repository         | Filter             |
|--------------------|--------------------|
| `acme-project`     | `#service=nginx`   |

__View: PostgreSQL Logs__

| Repository           | Filter              |
|----------------------|---------------------|
| `acme-project`       | `#service=postgres` |

__View: iOS App Analytics__

| Repository           | Filter                                  |
|----------------------|-----------------------------------------|
| `acme-project`       | `#service=app and eventType=analytics`  |

In this example we create three views that all draw their data from
a single repository. If you are using a free cloud account the
repository could be you [Sandbox]({{< relref "the_sandbox.md" >}})

#### Redacting sensitive information {#sensitive}

Your data may contain information that not everyone should have access to.
You can use a view to implement security restrictions and censoring.

Let's say your logs contain social security numbers and you don't want your
help desk workers to be able to see these. You can redact them by overriding
the field (e.g. `socialSecurityNo`) that contains the sensitive info in the
filter expression:

| Repository         | Filter                                 |
|--------------------|----------------------------------------|
| `hospital-logs`    | `socialSecurityNo := "REDACTED"`       |

#### Restricting access to a subset of a repository {#subset}

Say your system produces logs in several regions, but some of the people who
have search access should only be able to see logs for their respective region.

It is easy to select a subset of the logs by filtering the results before they
reach the user.  in this case limiting access to logs Germany :

| Repository  | Filter                                        |
|--------------------|----------------------------------------|
| `website`          | `country = "DE"`                       |
| `db`               | `ip.geo = "DE"`                        |

In this example we are dealing with two repositories.


#### Field Aliases

In the [previous example]({{< relref "#subset" >}}) we saw that two repositories
had the same information but in two different fields depending on your parsers and
the logging format. That would mean in order
to search for all events from the "UK"-region we would have to write a query like:

```humio
country = "UK" or ip.geo = "UK"
```

This is repetitive and clumsy. Instead we can define a new field as part of the
filter expressions:

| Repository         | Filter                                                         |
|--------------------|----------------------------------------------------------------|
| website            | `region := country`                                            |
| db                 | `region := ip.geo`                                             |

Now you can just write:

```humio
region = "UK"
```

---
title: Repositories
---

Humio organizes data into _Repositories_ (or _Repos_). Each repository has its
own set of users, dashboard, saved queries etc.

A repository is container for data with associated storage.
Often you will have one physical repository per project or system. But the use-cases
very based on your data volume, and many other factors.

On a physical repository you can control retention and assign
[parsers]({{ ref "parsers.md" }}) that define how data is stored.

When [sending data to humio]({{< ref "sending_data_to_humio/_index.md" >}}) you always
specify a repository and a [parser]({{< ref "sending_data_to_humio/parsers/_index.md" >}}) as the target.

## Views

The repository has a close cousin called a [View]({{< relref "views.md">}}).
You can think of a view as a kind of a _virtual repository_, and is works similarly
to the views you may know from SQL databases.

While a you can search directly in a repository, doing search through a view
gives you some added benefits, e.g.:

- Joining logs from multiple repositories in a single search
- You can restrictions results to a subset of a repository's data
- Redacting sensitive fields
- Keeping find-grained control of data retention

You can read more about views in the [view documentation]({{< relref "views.md">}}).  

## The Sandbox

All accounts have a special _private_ repository called [the sandbox]({{< relref "the_sandbox.md" >}}) that that is. Unlike other
repositories you cannot add additional users or change retention. You can use for testing things out
or as the your main repo if your needs are simple.

{{% notice cloud %}}
If you are using a the free version of [Humio Cloud](https://cloud.humio.com) the sandbox
is your main storage repository and is where you send all your logs and events. You can
[use views to make your data easier to navigate]({{< relref "views.md#per-service" >}})
if you have logs from several sources.
{{% /notice %}}

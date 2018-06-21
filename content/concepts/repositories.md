---
title: Repositories
aliases: ["getting_started/repositories"]
---

Humio organizes data into _Repositories_ (or _Repos_). Each repository has its
own set of users, dashboards, saved queries, parsers, etc.

A repository is a container for data with associated storage.
Often you will have one physical repository per project or system. But use-cases
vary based on your data volume, user permissions and many other factors.

On a repository you can control retention and create
[parsers]({{< relref "parsers/_index.md" >}}) to parse incoming data.

When [sending data to humio]({{< relref "sending-data/_index.md" >}}) it will end up in a repository.

## Views

The repository has a close cousin called [Views]({{< relref "views.md">}}).
Views are similarly to the views you may know from SQL databases.

Views lets you search across multiple repositories. They also have user management and search filters, making it possible to define which users can see what data.
This is how fine grained access controls is implemented in Humio

You can search directly in a repository, or search through a
view.
 Using a view can give added benefits, e.g.:

- Joining data from multiple repositories in a single search
- Restrict results to a subset of a repository's data
- Redacting sensitive fields
- Keeping find-grained control of data retention

You can read more about views in [their doc section]({{< relref "views.md">}}).  

## The Sandbox

All accounts have a special _private_ repository called [the sandbox]({{< relref "the-sandbox.md" >}}). Unlike other
repositories you cannot add additional users or change retention. You can use the sandbox for testing things out
or as the your main repo if your needs are simple.

{{% notice cloud %}}
If you are using a the free version of [Humio Cloud](https://cloud.humio.com) the sandbox
is your main storage repository and is where you send all your logs and events. You can
[use views to make your data easier to navigate]({{< relref "views.md#per-service" >}})
if you have logs from several sources.
{{% /notice %}}

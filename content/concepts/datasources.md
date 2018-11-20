---
title: Datasources
---

A _datasource_ is a set of [events]({{< ref "events.md" >}}) that share
the the same [tags]({{< ref "tagging.md" >}}).

Each datasource is stored separately on disk. Restricting searches to a datasource
means Humio does not have to traverse all data - which makes searches much faster.

## Viewing a repository's datasources

In the settings page of a repository you can see the list of datasources that have
been created during ingest.

Datasources are created automatically based on  the tags assigned to incoming
events - whenever a new combination of tags is encountered during ingest a new datasource is created.

## Deleting a datasource

Datasources are the smallest unit of data that you can delete in Humio.
You can delete an entire datasource from the repository setting page.

## Memory usage

We recommend that you limit the number of datasources per Humio server to
a maximum of 1000 distinct datasources across all repositories.

Each datasource requires Java heap space for buffering events while building the
blocks of data to be persisted to disk - roughly 5 MB of memory per datasource.

In a clustered environment only the share of datasources that
are being "digested" on a particular node need heap for buffers.
In other words, more servers can accommodate more datasources.

__Example__  
If you have 1000 datasources in total across all repositories on a single
Humio server, you will need at least 5GB of heap just for buffering events.

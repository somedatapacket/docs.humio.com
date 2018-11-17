---
title: Datasources
---

A _datasource_ is a set of [events]({{< ref "events.md" >}}) that share
the the same [tags]({{< ref "tagging.md" >}}).

Each datasource is stored separately on disk and restricting searches to a subset
means Humio does not have to traverse all data - which can make searches much faster.

## Viewing a repository's datasources

In the settings page of repository you can see the list of datasources that have
been created for during ingest.

Datasources are created automatically based on  the tags assigned to incoming
events - whenever a new combination of tags is encountered during ingest a new datasource is created.

## Deleting a datasource

Datasources are the smallest unit of data that you can delete in Humio.
You can delete an entire datasource from the repository setting page.

## Memory usage

We recommend that you limit the number of datasources per Humio server to
a maximum of 1000 distinct datasource across all repositories.

Each datasource requires Java heap space for buffering events while building the
blocks of data to be persisted to disk - roughly 5 MB per datasource of memory.

In a clustered environment, only the share of datasources that
are being "digested" on this particular node need heap for buffers.
So more servers can accommodate more datasources in the cluster.

__Example__  
If you have 1000 datasources (across all repositories, in total) on a single
Humio server, you will need at least 5GB of heap just for buffering events.

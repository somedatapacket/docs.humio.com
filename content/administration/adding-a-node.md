---
title: Adding a New Node
draft: true
related:
  - removing-a-node.md
  - instance-sizing.md
  - updating-humio.md
---

There are several reasons why you might want to add more nodes to your Humio
cluster including:

- High Availability
- Increased Query Performance
- Increased Storage Capacity
- Some nodes for storage and others for query processing or API access.

This guide takes you through the steps involved in adding a new node to your
cluster.

## Steps to adding a new cluster node

When a new node joins a Humio cluster it will initially not be responsible
in [digesting]({{< ref "ingest-flow.md#digention" >}}) or storage of
incoming data.

---
title: Digest Rules
aliases: [ref/digest-rules]
related:
  - storage-rule.md
  - ingest-flow.md
---

[Digest nodes]({{< ref "cluster-nodes.md#digest-node" >}}) are responsible for
executing real-time queries and compiling incoming events into segment files.

Whenever parsing is completed new events are placed in a Kafka queue called the
[Digest Queue]({{< ref "ingest-flow.md#parse" >}}).


## Digest Partitions {#partitions}

A cluster will divide data into partitions (or buckets), we cannot know exactly
which partition a given event will be put in -
Partitions are chosen randomly to spread the workload evenly across digest nodes.

Each partition of that queue must have a node associated to handle the work that
is placed in the partition or they would never be processed and saved.

Humio clusters have a set of rules that associate partitions in the Digest Queue
with the nodes that are responsible for processing events on that queue. These
are called _Digest Rules_.


## Configuring Digest Rules

You can see the current Digest Rules for your own cluster by going to the
Cluster Management Page and selecting the Digest Rules tab on the right-hand side:

{{< figure src="/pages/ingest-flow/digest-rules.png" class="screenshot" caption="The Cluster Management Page showing Digest Rules for a cluster of 3 nodes where each node is assigned to 8 out of 24 digest partitions." >}}

When a node is assigned to at least one digest partition, it is considered to be a Digest Node.

<!-- TODO: Add information about HA -->

__Example Digest Rules__

| Partition ID | Node         |
|--------------|--------------|
| 1            | 1            |
| 2            | 3            |
| 3            | 1            |

The table shows three digest rules. Node `1` will receive 2x more work
than node `3`. This is because `1` is assigned to two partitions while node `3`
is only handling events on partition `2`.

If a node is not assigned to a partition, it will not take part in the digest
phase.


## Removing a Digest Node {#removal}

When [removing a digest node]({{< ref "removing-a-node.md" >}}) it is important
that you first assign another cluster node to take the work in any digest partitions
that the node is assigned to. If you do not do this, there will be no one to process
the incoming events and it will stack up, and in the worst case data might get lost.

### High Availability

Humio is introducing High-Availability for ingest nodes, and will allow you to
assign failover nodes in each digest rule. This will mean that you don't have to
be quite so careful and that digest nodes can fail without impacting the systems
ability to function.  

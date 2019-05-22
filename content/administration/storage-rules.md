---
title: Storage Rules
aliases: ["/ref/storage-rules"]
---

In Humio data is distributed across the cluster nodes. Which nodes store what
is chosen randomly. The only thing you as an operator can control is how big a
portion is assigned to each node, and that multiple replicas are not stored on the
same rack/machine/location (to ensure fault-tolerence).

Data is stored in units of _segments_, which are compressed files between 0.5GB and 1GB.

## Storage Partitions {#partitions}

A cluster will divide data into partitions (or buckets), we cannot know exactly
which partition a given data segment will be put in -
Partitions are chosen randomly to spread the data evenly across nodes.

The number of partitions is configurable but that is not important initially -
the default number is 48 partitions.


## Configuring Storage Rules

Data is distributed according to the cluster's Storage Rules.
A _Storage Rule_ is a relation between a [storage partition]({{< ref "#partitions" >}}) and
the set of nodes that should store all data that written to that partition.

When a [digest node]({{< ref "cluster-nodes.md#digest-node" >}}) completes a data
segment file (the internal data unit in Humio) it is assigned to a random storage
partition. Here is an example configuration:

__Example Storage Rules__

| Partition ID | Nodes        |
|--------------|--------------|
| 1            | 1,2          |
| 2            | 3,4          |
| 3            | 1,2          |

In this example the cluster is configured with 3 storage partitions and 4 nodes.
Nodes `1` and `2` will receive 2/3 of all data written to the cluster, while nodes `3` and `4` only store 1/3 of all data.
This is because `1` and `2` archive all data in partitions `1` and `3`, while nodes `3` and `4` only archive the data in partition `2`.


## Replication Factor {#replication}

Notice that in the example above there are the same number of nodes per partition.
This is because we want a replication factor of __2__, meaning that all data is
stored on 2 nodes. If you had a partition with only 1 associated node, the
replication factor will effectively be 1 for the entire cluster! This is because
you cannot know which data goes into an given partition - and it does not make
sense to say that a random subset of the data should only be stored in 1 copy.

If you want fault-tolerence you should ensure your data is replicated across
multiple node, physical servers and geographical locations.


## UI for Storage Nodes {#ui}

The Cluster Nodes Administration Page can be found under the Account Menu by selecting
`Administration` -> `Cluster Nodes`. On the right-hand side of the screen the
Storage Rules Table is displayed.

{{< figure src="/pages/ingest-flow/storage-rules.png" class="screenshot" caption="Storage Rules, a cluster of 3 nodes where each node is assigned to 2 out of 3 archive partitions leading to a replication factor of 2." >}}

_There is also a tab for [Digest Rules]({{< ref "digest-rules.md" >}}) and it is important to understand that the
Digest Partitions and Storage Partitions are not related in any way. E.g a Digest Partition with `ID=1` does not contain the same data
as are written to the Storage Partition with `ID=1`._


## Storage Divergence {#divergence}

Humio is capable of storing and searching across huge amounts of data.
When [cluster nodes]({{< ref "cluster-nodes.md" >}}) join or leave the cluster, data
will usually need to be moved between nodes to ensure the replication factor is
upheld and that no data is lost.

If you system contains very large amounts of data you cannot simply
_shuffle it around_ whenever a node leaves or enters the system. That is because moving
Terabytes or Petabytes of data over the network can take a very long time and
potentially impact system performance if done at the wrong time.

Data is stored in Humio according to the cluster's Storage Rules, but when these
rules are changed, e.g. when a storage node fails and is removed from the cluster,
data is _not_ automatically redistributed to match the new ruleset.

In other words the _Storage Rules only apply to new data that is ingested_. This means
that data can end up being stored in fewer replicas that the configured replication factor!
This is not necessarily a bad thing. It depends on how strict your replication
requirements are.

You can always [redistribute it to match the current rules]({{< ref "#redistribute-data" >}}),
but it is done as a separate step from changing rules.

At the top of the Cluster Node Management UI you can see the "Storage Divergence"
indicated. This will in effect be the amount of data that will need to be sent
between nodes in order to make the all the cluster's data conform to the current
rules.

FIXME: Image

### Example: Changing Retention Factor only applies to new data

Say you have a cluster and want to increase your replication factor to 4 instead
of the current 2 replicas.

This would require having 4 nodes in each storage rule - which sets
the [replication factor]({{< ref "#replication-factor">}}) to 4.

This change will __ONLY APPLY TO NEW DATA ENTERING THE SYSTEM__, all existing data
will only be kept in 2 copies!

The reason for this is that the increased replication factor would mean the _all_
data in the entire cluster would have to be transmitted between nodes. In a cluster
with a large amount of data this might not what you want.

### Example: A node is removed uncleanly

If you [remove a node]({{< ref "removing-a-node.md" >}}) from the cluster without
first handing over the node's data to other nodes, there will be one less version
of whatever data it was holding.

In this case that effective data distribution will diverge from the current
rules, indicated by the _Too Low_ segment of the replication bar in the Cluster
Management UI.


## Redistribute Data to match the current Storage Rules {#redestribute-data}

If you want to make your make your effective data distribution match the
current storage rules you can use the Cluster Management UI.

At the bottom of the _Storage Rules Panel_ on the right-hand side of the screen
you can click _Show Options_, here you will be offered the option to _Start Transfers_.

If you click it you will see that the _Traffic_ column of the nodes will indicate
the shuffling of data around the cluster.

If you make a mistake, you can always undo the change and click "Start Transfers",
effectively undoing the change.

FIXME: Add image

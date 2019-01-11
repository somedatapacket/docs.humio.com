---
title: Replacing Hardware
---

If you want to replace a node in your cluster, say due to faulty hardware or
upgrade the hardware the node is running on you have a couple of options.

## About Cluster Node Identity {#uuid}

A cluster node is identified in the cluster by it's UUID. The UUID is
automatically generated the first time a node is started. The UUID is stored
in `$HUMIO_DATA_DIR/cluster_membership.uuid`. When moving/replacing a node you
can use this file to ensure a node rejoins the cluster with the same identity.

## Example Cases

This guide assumes a rather basic hardware and network setup. If you are using
SANs, Blue-Green Deployment, or other advanced techniques you can use this an
a reference to adapt to your situation.

### __Case 1__: The node will continue running with the same storage

<!-- TODO: Change for HA on Digest -->

If the node will continue to run on the same storage (meaning it keeps its data directory),
all you will need to do it to ensure that the node is not a [Digest Node]({{< ref "ingest-flow.md#digest" >}})
before shutting down the node:

#### __Step 1__: Assign another node to any Digest Rules where this node is assigned.

This can be done using the Humio's Management Cluster UI. You can read more about
[un-assigning digest in the section about removing a node]({{< ref "removing-a-node.md#unassign-digest" >}}).

#### __Step 2__: Shutdown the Humio process on the node

At this point you can see the node being unavailable in the Cluster Management UI.

#### __Step 3__: Replace the hardware components

#### __Step 4__: Start the Humio process

Your node should rejoin the cluster after a little while and you can see the node
become available in the Cluster Management UI.

#### __Step 5__: Reassign the Digest Rules (if you unassigned any in Step 1).



### __Case 2A__: The node will use a new storage unit (Slow Recovery)

You are moving the node to completely other machine or installing a new disk or SSD.

There are two requirements that must be fulfilled:

1. If your cluster has multiple replicas of data ([Replication Factor]({{< ref "ingest-flow.md#replication" >}}) >= 2)
and it is acceptable for the cluster to be in a state of lower replication
while the new hardware is being provisioned.

1. You must also make sure that the node does not contain any data that it is the sole
owner of (this can e.g. occur if you have [archive divergence]({{< ref "storage-rules.md#divergence" >}})).
You can check this in the Cluster Management UI, indicated by red numbers in the _Size_ column.

In this case the cluster can self-heal once the node reappears. It will discover
that the node is missing data is was expected to have and start resending it.

#### __Step 1__: Make a copy of the Node UUID file

While you won't have to copy all the data on the node you must make a backup of the Node UUID file.
It is located in `$HUMIO_DATA_DIR/cluster_membership.uuid`, you will be copying it to the new data folder
on the new storage unit.

#### __Step 2__: Assign another node to any Digest Rules where this node is assigned.

This can be done using the Humio's Management Cluster UI. You can read more about
[un-assigning digest in the section about removing a node]({{< ref "removing-a-node.md#unassign-digest" >}}).

#### __Step 3__: Shutdown the Humio process

#### __Step 4__: Copy the Node UUID file from _Step 1_ into the node's data folder

#### __Step 5__: Start the Humio process using the new storage

Your node should rejoin the cluster after a little while and you can see the node
become available in the Cluster Management UI.

You will see that the other nodes will start resending all the data that is missing
on the node and that the _Too Low_ segment of the replication status in the header
will initially be high, but start dropping as data is replicated.

#### __Step 6__: Reassign the Digest Rules (if you unassigned any in Step 2).


### __Case 2B__: The node will use a new storage unit (Quick Recovery)

If you are moving node to a new storage unit and have hard replication requirements
or your cluster is only storing data in one replica, you cannot use [Case 2A]{{< ref "#case2a" >}}.

To limit the downtime of your node you should copy node's data directory before and
shutting down the original node, this will ensure you only have to copy the most recent
data when the node is taken offline.

#### __Step 1__: Use RSync or similar to copy the data directory to the new storage (this includes the [UUID File](#uuid)).

#### __Step 2__: Assign another node to any Digest Rules where this node is assigned.

This can be done using the Humio's Management Cluster UI. You can read more about
[un-assigning digest rules]({{< ref "removing-a-node.md#unassign-digest" >}})  in the section about removing a node.

#### __Step 3__: Reassign any Archive Rules to other cluster nodes.

This can be done using the Humio's Management Cluster UI. You can read more about
[un-assigning archive rules]({{< ref "removing-a-node.md#unassign-archive" >}}) in the section about removing a node.

#### __Step 4__: Shutdown the Humio process

#### __Step 5__: Rerun RSync or similar to copy the most recent data to the new storage.

#### __Step 6__: Start the Humio process

Your node should rejoin the cluster after a little while and you can see the node
become available in the Cluster Management UI.

#### __Step 7__: Reassign the Digest Rules and Archive Rules (if you unassigned any in Step 2 and 3).


### __Case 3__: Storage malfunctions and you're running without replication or the node had data not found on other nodes anywhere else

In the case where storage cannot be recovered, there are two options:

1. Restore the node from backup if you have that enabled. See [Restoring from Backup]({{< ref "backup.md#restoring" >}})

2. Forcibly Remove the node from the cluster. Any data that was not stored in multiple
   replicas will be lost. See [Force Remove a Node]({{< ref "removing-a-node.md#force" >}})

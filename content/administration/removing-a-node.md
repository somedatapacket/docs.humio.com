---
title: Removing a Node
---

To safely remove a node from a Humio cluster you need to ensure that the data
stored on the node is completely copied to another node before it leaves.

## Steps to removing a cluster node

When you want to remove node from a cluster you need to make sure that
any digest and archiving responsibilities. This means removing the node from
any Digest and Archive Rules. This will stop the node from accepting any new
work. The data stored on the node would be copied to another node to keep the
cluster's replication factor stable.

We will be using the Cluster Node UI in this guide, but everything can be
automated using the [Cluster Management GraphQL API]({{< ref "graphql.md#api-explorer" >}})
we will be listing the associated HTTP calls performed in each step.

The Cluster UI will indicate that a node is safe to remove from the cluster with
a `Yes` in the _Removable_ column.

### Step 1: Un-assign Digest Rules {#unassign-digest}

If the node is being used for digest (the _Digest_ column has a value greater than 0),
you need to stop accepting new digest work by removing the node from all Digest Rules.

In the Cluster UI follow these steps:

1. Select the node you want to remove in the list of nodes
1. In the panel labeled _Actions_ click the item labeled __Stop using this node for digest of incoming data__ and then __Remove node from Digest Rules__.

This will automatically assign other suitable nodes to the digest partitions currently
assigned to the node you want to remove.

### Step 2: Un-assign Archive Rules {#unassign-archive}

If the node is being used for archiving (the _Archive_ column has a value greater than 0),
you need to stop archiving new data by removing the node from all Archive Rules.

In the Cluster UI follow these steps:

1. Select the node you want to remove in the list of nodes
1. In the panel labeled _Actions_ click the item labeled __Stop using this node for storing for incoming data__ and then __Remove node from Storage Rules__.

This will automatically assign other suitable nodes to the Archive partitions
currently assigned to the node you want to remove.

### Step 3: Moving all data to other nodes

Finally you need to move all archived on the node other nodes to ensure that
the cluster's replication factor is upheld before the node is removed.

In the Cluster UI follow these steps:

1. Select the node you want to remove in the list of nodes
1. In the panel labeled _Actions_ click the item labeled __Move all existing data away from this node__ and then __Move data out of node__.


### Step 4: Shut down the Humio Process on the node

You should shut down the Humio process on the node.
You must wait until the _Size_ column of the Node List shows _0 B_ indicating that
no more data resides on the node.

### Step 5: Unregister from the cluster

Finally you should see that the _Removable_ column says Yes, and you can
unregister the node from the cluster - i.e. telling other nodes that the node
will not be coming back again.

In the Cluster UI follow these steps:

1. Select the node you want to remove in the list of nodes
1. In the panel labeled _Actions_ click the item labeled __Remove Node__ and then click the button __Remove Node__.

#### Forcing Removal {#force}

If a node has died and there is no backup and no way of retrieval of the data
you can forcibly unregister the node. This means that you will have to accept
potential data loss, if no replicas of the data existed!

You can forcibly remove a node by checking the checkbox __Force Remove__ in the UI.

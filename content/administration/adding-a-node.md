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
in processing any incoming data.

There are three core tasks a node perform, Parsing, Digest and Archiving.
You can read ingestion flow documentation if you want to know more about the
different node tasks, but for now we will assume that the node we are adding
should take its fair share of entire workload.

We are going to use the Cluster Node Administration UI but every step can be
performed and automated using [Cluster Management GraphQL API]({{< ref "graphql.md#api-explorer" >}})
we will be listing the associated HTTP calls performed in each step.

### 1. Starting a new Humio Node

The first step is to start the Humio node and point it at the cluster. You can
read about how to configure a node in the [cluster installation guide]({{ ref "cluster_setup.md#running-humio"}}).

The important part is that the `KAFKA_SERVERS` configuration option
points at the Kafka servers for the existing cluster.

Once the node has successfully joined the cluster it will appear in the
Cluster UI's list of nodes.

Notice that the columns _Archive_ and _Digest_ both say `0 / X`. That is because
at this point you the new node's storage will note be used - indicated by the `0` in the _Archive_ column) -
and it will not be used for digest (processing of events running of real-time queries) -
indicated by the `0` in the _Digest_ column.

A node configured like this is called an _Arrival Node_ since its only task
is to parse messages as it _arrives_ at the Humio cluster.

### Step 2: Assigning digest work to the node

We want our new node to do some of the digest workload. Digest is the process
of looking at incoming events and updating the results of currently running searches,
(i.e. updating the data displayed dashboard widgets and search results).

To distribute a fair share of the digest work to the new node you can use the
Cluster UI and follow these steps:

1. Select the node in the list
1. In the panel labeled _Node Tasks_ click the item labeled __Start using this node for digest of incoming data__ and then __Add node to Digest Rules__.

This will change the Digest Rules (seen on the right of the screen) to include the new node.

_Initially you should not don't too much if you don't understand how Digest and Archive Rules
work, suffice to say that they work like a routing table for internal cluster traffic and determines
which node does what. You can read a more [advanced description of Digest Rules]({{< ref "ingest-flow.md#digest-rules" >}})
in the Ingest Flow documentation_

<!-- TODO: Update for high availability -->

Once you have clicked the button and wait a few seconds, you should see that the
node now has a share if the digest workload assigned to it, indicated by the value
of the column _Digest_ being greater than zero.

### Step 3: Using the node for archiving

We would also like to use the storage of the node for archiving data. This means
that the node's SSD or disk will be used to store data and that the node does part
of the worked involved with searching (i.e. executing a query on the cluster).

To use node for archiving of new events follow these steps:

1. Select the node in the Cluster UI
1. In the panel labeled _Node Tasks_ click the item labeled __Start using this node for storing incoming data__ and then __Add node to Archive Rules__.

This changes the Archive Rules (seen on the right of the screen) to include the node.
What this means is that part new incoming data (not existing data) will be stored
on the node.

_Just like with Digest Rules, Archive Rules are an advanced topic, and you don't need to
fully understand them when getting started. In a nutshell Archive Rule define where data is stored
and in how many replicas. You can read a more detailed [description of Archive Rules and Replication]({{< ref "ingest-flow.md#digest-rules" >}})
in the Ingest Flow documentation_

### Step 4: Taking part of the existing archived data

Lastly we would like to have the node to take part of the existing data that was
already in the cluster before it joined. This does not happen automatically as you
might expect _- this is because moving a potentially huge amount of data between
cluster node can adversely impact performance and you might want to do it during the night
or similar._

To move a fraction of the total data stored in the cluster to the node, the fraction shown in the _Archive_ column
follow these steps:

1. Select the node in the Cluster UI
1. In the panel labeled _Node Tasks_ click the item labeled __Move a share of existing data onto this node__ and then __Move data to node__.

You will see that the "Traffic" column of the node list will indicate that data is
being moved to the node.


## Done

Steps 2-4 are all optional and in more advanced setups, you will only do some
of them. It is recommended that you read the [Ingest Flow documentation]({{< ref "ingest-flow.md#digest-rules" >}}) to
understand Digest and Archiving in detail.

---
title: "Ingest Flow"
---

When data arrives at Humio it needs to be processed. The journey data takes from
arriving at a Humio node until it is presented in search results and archived to disk
is called the __ingest flow__.

If you are planning a large system or tuning the performance of your Humio cluster it can help
to understand the flow of data. E.g. if you understand the different phases of the ingest flow
you can ensure that the right machines have the optimal hardware configuration.

In this section we'll explains the different ingest phases and how nodes participate.

## Parsing, Digest and Storage

There are three phases a incoming data goes through:

<figure>
{{<mermaid align="center">}}
graph LR;
  x{"Data"} --> Parse
  Parse --> Digest
  Digest --> Archive
{{< /mermaid >}}
</figure>

1. __Parse__: Receiving messages over the wire and processing them with parsers.
2. __Digest__: Building segment files and buffering data for real-time queries.
3. __Archive__: Replicating the segments files to designated nodes and processing historical queries.

These phases may handled by different nodes in a Humio cluster, or a
single node can take part in any combination of the three. Sometimes you may want
to specialize certain nodes with higher CPUs or RAM to tune performance.

## The __Parse__ Phase {#parse}

<figure>
{{<mermaid align="center">}}
graph LR;
  Data{"Data"} --> Parse
  Parse --> Digest
  Digest --> Archive
style Parse fill:#2ac76d;
{{< /mermaid >}}
</figure>

When an system sends data (e.g. logs) to Humio over one of the
[Ingest APIs]({{< ref "ingest-api.md" >}}) or through an [ingest listener]({{< ref "ingest-listeners.md" >}})
the cluster node that receives the request is called the [arrival node]({{< ref "node-roles.md#arrival-node" >}}).
The arrival node parses the incoming data and puts result (called an [event]({{< ref "events.md" >}})
on a Kafka message queue. The event is now ready to be processed by a Digest Node.

<figure>
{{<mermaid align="center">}}
graph LR;
  subgraph External
    Ext1[External Service]
  end

  subgraph Ingest
  Ext1 --> A1("<b>Arrival Node</b>")
  end

  subgraph Kafka
    P1["Partition <em>#1</em>"]
    A1 --> P2["Partition <em>#2</em>"]
    PN["Partition <em>#N</em>"]
  end
{{< /mermaid >}}
</figure>

Exactly which partition the event ends up on is chosen at random. If you are not
familiar with Kafka, don't worry. You can think of a partition has a queue of work
ready to be processed.

## The __Digest__ Phase {#digest}

<figure>
{{<mermaid align="center">}}
graph LR;
  Data{"Data"} --> Parse
  Parse --> Digest
  Digest --> Archive
style Digest fill:#2ac76d;
{{< /mermaid >}}
</figure>

After an event is placed in the digest queue a [Digest Node]({{< ref "node-roles.md#digest" >}})
will grab it off the queue as soon as possible. Each Kafka partition has a node
assigned to it, this is the node that does all the processing of event that end up
there. A single node can handle multiple partitions and exactly which node that
handles which partition is defined in the cluster's _Digest Rules_.

### Digest Rules {#digest-rules}

Each cluster has a table of rules that associates partitions in the Digest Queue
with the nodes that process events on that queue. You can see the digest rules
for your own cluster by going Cluster Node Administration page and selecting the
Digest Rules tab:

{{< figure src="/pages/ingest-flow/digest-rules.png" class="screenshot" caption="Digest Rules, a cluster of 3 nodes where each node is assigned to 8 out of 24 digest partitions." >}}

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

If a node is not assigned to a partition, it will not take part in the digest phase.

### Real-Time Query Results {#real-time}

Digest node also produces the Real-Time part of search results. They to this by
using processing new events that enter the system but before they are archived.

In other words: Whenever a new event is pulled off the digest queue the
digest node examines it and updates the results of any matching queries that are
currently running.

### Segment Files {#segment-files}

Digest nodes are responsible buffering new events and compiling segment
files (the files that are written to disk in the Archive Phase).

Once a segment file if full, it is passed on to Storage Nodes in the Archive Phase.


## The __Archive__ Phase {#archive}

<figure>
{{<mermaid align="center">}}
graph LR;
  Data{"Data"} --> Parse
  Parse --> Digest
  Digest --> Archive
style Archive fill:#2ac76d;
{{< /mermaid >}}
</figure>

The final phase of the ingest flow is archiving. Once a segment file has been
closed in the digest phase it is saved in _X_ replicas - how many depend on how
your cluster is configured.

### Replication & Archive Rules

If you want fault-tolerence you should ensure your data is replicated across
multiple node and physical locations. To do this you use configure your cluster's _Archive Rules_,
and just like with [Digest Rules]({{< ref "#digest-rules" >}})
the associate a partition of data with nodes responsible for handling them.

If you take a look at the Cluster Nodes Administration Page you can see that
each entry in the Archive Rules Table associates a partition with a set of nodes -
exactly which partitions are associated with which nodes are only important if
you want to ensure the physical separation of data replicas.

{{< figure src="/pages/ingest-flow/archive-rules.png" class="screenshot" caption="Archive Rules, a cluster of 3 nodes where each node is assigned to 2 out of 3 archive partitions leading to a replication factor of _2_." >}}

_It is important to understand that the Digest Partitions and Archive Partitions
are not related in anyway. E.g a Digest Partition with ID=1 does not contain the same events
as are written to the Archive Partition with ID=1.__

__Example Archive Rules__

| Partition ID | Nodes        |
|--------------|--------------|
| 1            | 1,2          |
| 2            | 3,4          |
| 3            | 1,2          |

The table shows three archive rules. Nodes `1` and `2` will receive 2x more data
than nodes `3` and `4`. This is because `1` and `2` archive all data in partitions
`1` and `3`, while nodes `3` and `4` only archive the data in partition `2`.

If a node is not assigned to a partition, it will not store any data on disk and
wont be used for searching in historical segments when executing a search on the
cluster.

#### Replication Factor

Notice that in the table above there are the same number of nodes per partition.
This is because we want a replication factor of __2__, meaning that all data is
stored on 2 nodes. If you had a partition with only 1 associated node, the
replication factor will effectively be 1 for the entire cluster! This is because
you cannot know which data goes into an given partition - and it does not make
sense to say that a random subset of the data should only be stored in 1 copy.

## Detailed Flow Diagram

Now that we have covered all the phases, let's put the pieces together and give
you a more detailed diagram of the complete ingest flow:

<figure>
{{<mermaid align="center">}}
graph LR;
    subgraph External Systems
      Ext1[Data Producer]
      Ext2[Log System]
    end

    subgraph Humio Cluster

      subgraph Ingest
        A1("<b>Arrival Node <em>#1</em></b><br><em>Parsing</em>")
        A2("<b>Arrival Node <em>#2</em></b>")
        AN("<b>Arrival Node <em>#N</em></b>")

        Ext1 -->|Ingest| A1
        Ext2 -->|Ingest| A1
      end

      subgraph Kafka
        A1 -.-> P1["Partition <em>#1</em>"]
        A1 --> P2["Partition <em>#2</em>"]
        A1 --> P3["Partition <em>#3</em>"]
        A1 -.-> PN["Partition <em>#M</em>"]
      end

      subgraph Digest
        P2 --> D1("<b>Digest Node <em>1</em></b><br><em>Real-Time Query Processing<br>Builds Segment Files</em>")
        P3 --> D1

        D2("<b>Digest Node <em>#2</em></b>")
        DN("<b>Digest Node <em>#P</em></b>")
      end
      subgraph Archiving
        S1("<b>Storage Node <em>#1</em></b>")
        D1 --> S2("<b>Storage Node <em>#2</em></b>")
        D1 --> SN("<b>Storage Node <em>#Q</em></b>")
      end
    end

    classDef faded opacity:0.3;
    class A2,AN,P1,PN,D2,DN,S1 faded;

{{< /mermaid >}}
<figcaption>
<a id="figure-2">Figure 2</a>: Two external systems send data and logs to Humio. The incoming data is first parsed by one of the the Arrival Nodes. Then it is put on the ingest queue for the Digest Node to process and produce segment files, before finally being sent to the Storage Nodes to be saved to disk.
</figcaption>
</figure>

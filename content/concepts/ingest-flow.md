---
title: "Ingest Flow"
---

When data arrives at Humio it needs to be processed. The journey data takes from
arriving at a Humio node until it is presented in search results and saved to disk
is called the __ingest flow__.

If you are planning a large system or tuning the performance of your Humio cluster it can help
to understand the flow of data. E.g. if you understand the different phases of the ingest flow
you can ensure that the right machines have the optimal hardware configuration.

In this section we'll explain the different ingest phases and how nodes participate.

## Parse, Digest, Store

There are three phases incoming data goes through:

<figure>
{{<mermaid align="center">}}
graph LR;
  x{"Data"} --> Parse
  Parse --> Digest
  Digest --> Store
{{< /mermaid >}}
</figure>

1. __Parse__: Receiving messages over the wire and processing them with parsers.
2. __Digest__: Building segment files and buffering data for real-time queries.
3. __Store__: Replicating the segment files to designated storage nodes.

These phases may be handled by different nodes in a Humio cluster, but any
node can take part in any combination of the three phases.

## The __Parse__ Phase {#parse}

<figure>
{{<mermaid align="center">}}
graph LR;
  Data{"Data"} --> Parse
  Parse --> Digest
  Digest --> Store
style Parse fill:#2ac76d;
{{< /mermaid >}}
</figure>

When an system sends data (e.g. logs) to Humio over one of the
[Ingest APIs]({{< ref "ingest-api.md" >}}) or through an [ingest listener]({{< ref "ingest-listeners.md" >}})
the cluster node that receives the request is called the [arrival node]({{< ref "cluster-nodes.md#arrival-node" >}}).
The arrival node parses the incoming data (using the [configured parsers]({{< ref "parsers/_index.md">}}))
and puts the result (called [events]({{< ref "events.md" >}}))
in a Humio's `humio-ingest` Kafka queue.

If you are not familiar with Kafka - don't worry. 

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
<figcaption>Events are parsed and placed on a random digest partitions.</figcaption>
</figure>

The events are now ready to be processed by a Digest Node.

## The __Digest__ Phase {#digest}

<figure>
{{<mermaid align="center">}}
graph LR;
  Data{"Data"} --> Parse
  Parse --> Digest
  Digest --> Store
style Digest fill:#2ac76d;
{{< /mermaid >}}
</figure>

After the events are placed in the `humio-ingest` queue a [Digest Node]({{< ref "cluster-nodes.md#digest-node" >}})
will grab them off the queue as soon as possible. A queue in Kafka is configured with a number of partitions (parallel streams), and each such Kafka partition is consumed by a digest node.
A single node can handle consume multiple partitions and exactly which node that
handles which digest partition is defined in the cluster's [Digest Rules]({{< ref "digest-rules.md" >}}).

### Constructing Segment Files {#segment-files}

Digest nodes are responsible for buffering new events and compiling segment
files (the files that are written to disk in the _Store_ phase).

Once a segment file is full it is passed on to Storage Nodes in the Store Phase.

### Real-Time Query Results {#real-time}

Digest nodes also processes the Real-Time part of search results.
Whenever a new event is pulled off the `humio-ingest` queue the
digest node examines it and updates the result of any matching live searches
that are currently in progress. This is what makes results appear instantly in
results after arriving in Humio.


## The __Store__ Phase {#store}

<figure>
{{<mermaid align="center">}}
graph LR;
  Data{"Data"} --> Parse
  Parse --> Digest
  Digest --> Store
style Store fill:#2ac76d;
{{< /mermaid >}}
</figure>

The final phase of the ingest flow is saving segment files to storage. Once a segment file has been
completed in the digest phase it is saved in _X_ replicas - how many depend on how
your cluster is configured (see [Storage Rules]({{< ref "storage-rules.md" >}})).

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

      subgraph Parse
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
      subgraph Store
        D1 --> S1("<b>Storage Node <em>#1</em></b>")
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

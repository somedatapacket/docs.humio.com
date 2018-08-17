---
title: High availability
---

Humio is designed for high availability when being run as a cluster of
Humio nodes on multiple machines when using sufficient number of
replicas.

## What exactly does Humio provide for high availability?

The target is to handle total loss of one or more machines while not
loosing any acknowledged ingest events and without requiring operator
intervention.

To be able to handle the failure of `n` machines, Humio must be
configured to keep at least `n+1` replica of both "ingest partitions"
and "segment partitions".

When a node go missing, the remaining nodes configured to handle those
partitions take over on those. As a result those partitions go from
having `n` replicas of data to having `n-1` replicas. The cluster does
not add other nodes to those partitions. If more of the nodes on those
partitions go missing and there at some point is a partition that has
no live hosts, then the cluster is no longer functional.

Make sure there is sufficient capacity in the cluster to run the full
load of ingest an queries with `n-1`nodes missing, if you have `n`
replicas. As an example, in an 8-node cluster with a 3 replicas of
data, the system must be able to handle the normal workload on only 6
nodes and still have idle resources in terms of CPU, memory, disk and
network I/O.

Cascading faults where multiple nodes go missing, one after another,
but only one at a time, counts as "one failure" unless there is
sufficient time where all hosts are present at the same time between
the failures to allow the cluster to get back in "sync". Depending on
the load on the system this can be a considerable amount of time.


### But can Humio still drop events then?

When properly configured events should not get dropped unless multiple
failures happen within an interval that is too short for the cluster
to recover from one failure before the next occours.

Depending on the kind of failures, it is possible to get duplicate
events, since most client will retry on failure, and some events may
have been accepted by the Humio server even if the client did not get
a proper response.

When a Humio node processes only parts (or all) of an ingest request on
http, but the ingest client does not get the "200 OK" reponse, then
that ingest client will usually try to submit those events again. This
will result in duplicate and identical events that differ only on the
"@id" attribute assigned by the Humio server on ingest.

## Requirements

### Hardware

The cluster must consist of nodes on independent hosts in such a
manner that a problem on one host does not affect the other hosts.

Make sure to assign partitions to nodes in such a manner that the
nodes servicing a partition are as independent as possible, e.g. run
on independent hosts.

### Kafka and Zookeeper

Humio depends on Kafka and Zookeeper to be available to run. Make sure
your Kafka and Zookeeper clusters have enough nodes to be able to able
to support 3 replicas of Humio also in the case of failures of some of
those nodes. The recommended number of Kafka nodes is 5 or more.

### Humio nodes


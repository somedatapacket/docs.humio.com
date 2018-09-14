---
title: "Kafka Configuration"
---

Humio uses Kafka internally for queueing incoming messages and for
storing shared state when running Humio in a cluster setup.

In this section we briefly describe how Humio uses Kafka. Then we discuss how to configure Kafka.

{{% notice note %}}
Make sure to not apply compression inside Kafka to the queues below. Humio compresses the messages when relevant.
Letting Kafka apply compression as well slows down the system and also adds problems with GC due to use of JNI in case LZ4 is applied.
Setting `compression.type` to `producer` is recommended on these queues.
{{% /notice %}}

## Queues

Humio creates the following queues in Kafka:

* [global-events]({{< ref "#global-events" >}})
* [global-snapshots]({{< ref "#global-snapshots" >}})
* [humio-ingest]({{< ref "#humio-ingest" >}})
* [transientChatter-events]({{< ref "#transientChatter-events" >}})

You can set the environment variable `HUMIO_KAFKA_TOPIC_PREFIX` to add that prefix to the topic names in Kafka.
Adding a prefix is recommended if you share the Kafka installation with applications other than Humio, or with another Humio instance.
The default is not to add a prefix.

Humio configures default retention settings on the topics when it creates them.
If they exist already, Humio does not alter retention settings on the topics.

If you wish to inspect and change the topic configurations, such as the retention settings,
to match your disk space available for Kafka, please use the `kafka-configs` command.
See below for an example, modifying the retention on the ingest queue to keep burst of data for up to 1 hour only.


### global-events
This is Humio's event sourced database queue. This queue will contain small events, and has a pretty low throughput.
No log data is saved to this queue. There should be a high number of replicas for this queue. Humio will raise the number of replicas on this queue to 3 if there are at least 3 brokers in the Kafka cluster.

Default retention configuration: `retention.ms = 30 days`

### global-snapshots
This is Humio's database snapshot queue. This queue will contain few but fairly large events, and has a pretty low throughput.
No log data is saved to this queue. There should be a high number of replicas for this queue. Humio will raise the number of replicas on this queue to 3 if there are at least 3 brokers in the Kafka cluster.

Default retention configuration: `retention.ms = 30 days`

### humio-ingest
Ingested events are send to this queue, before they are stored in Humio. Humio's
frontends will accept ingest requests, parse them and put them on the queue.
The backends of Humio is processing events from the queue and storing them into Humio's datastore.
This queue will have high throughput corresponding to the ingest load.
The number of replicas can be configured in accordance with data size, latency
and throughput requirements and how important it is not to lose in flight data.
Humio defaults to 2 replicas on this queue, if at least 2 brokers exist in the Kafka cluster,
and Humio has not been told otherwise through the configuration parameter `INGEST_QUEUE_REPLICATION_FACTOR`, which defaults to "2".
When data is stored in Humio's own datastore, we don't need it on the queue anymore.

Default retention configuration: `retention.ms = 48 hours`

### transientChatter-events
This queue is used for chatter between Humio nodes.  It is only used for transient data.
Humio will raise the number of replicas on this queue to 3 if there are at least 3 broker in the Kafka cluster.
The queue can have a short retention and it is not important to keep the data, as it gets stale very fast.

Default retention configuration: `retention.ms = 1 hours`

## Configuration

Humio has built-in [API endpoints for controlling Kafka]({{< relref "cluster-management-api.md" >}}).
Using the API it is possible to specify partition size, replication factor, etc. on the ingest queue.

It is also possible to use other Kafka tools, such as the command line tools included in the Kafka distribution.


### Setting retention on the ingest queue

Show ingest queue configuration. (This only shows properties set specifically for the topic - not the default ones specified in `kafka.properties`:

```shell
<kafka_dir>/bin/kafka-configs.sh --zookeeper $HOST:2181 --entity-name humio-ingest --entity-type topics --describe
```

Set retention on the ingest queue to 1 hour.

```shell
<kafka_dir>/bin/kafka-configs.sh --zookeeper $HOST:2181 --entity-name humio-ingest --entity-type topics --alter --add-config retention.ms=3600000
```

Set retention on the ingest queue to 1GB (per partition)

```shell
<kafka_dir>/bin/kafka-configs.sh --zookeeper $HOST:2181 --entity-name humio-ingest --entity-type topics --alter --add-config retention.bytes=1073741824
```

{{% notice note %}}
The setting `retention.bytes` is per partition. By default Humio has 24 partitions for ingest.
{{% /notice %}}

## Kafka broker settings
If your Humio instance has a lot of data then the "global-snapshots" topic requires large messages.
If you use the Kafka brokers only for humio, you can configure the kafka brokers to allow large message on all topics. This example allows up to 100MB in each message. Note that larger sizes makes the brokers need more memory for replication.

```
# setup to allow large messages - messages on "global-snapshots" can get big
replica.fetch.max.bytes=104857600

# max message size for all topics by default:
message.max.bytes=104857600
```

Another option is to configure the global-snapshots topic to allow larger messages on that topic only:

```shell
<kafka_dir>/bin/kafka-configs.sh --zookeeper $HOST:2181 --entity-name global-snapshots --entity-type topics --alter  --add-config max.message.bytes=104857600
```

If you have very large amounts of data (say petabytes) in Humio you may need to increase beyond 100MB.

{{% notice note %}}
If you run your own Kafka (i.e. not the one provided by Humio) you must increase the max.message.bytes on the global-snapshots topic as desacribed above, or raise the default on your existing brokers.
{{% /notice %}}

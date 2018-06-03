---
title: "Kafka connect"
---

[Kafka Connect](https://kafka.apache.org/documentation/#connect) is a framework for connecting Kafka with other systems such as Humio. If you have your data in Kafka, consider this approach for sending data to Humio.

As Humio supports ingesting data using the Elasticsearch bulk api, data can be send to Humio using the [Elasticsearch Connector] (https://docs.confluent.io/current/connect/connect-elasticsearch/docs/elasticsearch_connector.html) build by Confluent.

The Kafka Connect framework is part of the standard Kafka download. But the Confluent Elasticsearch Connector must be downloaded separately. It is available in the Docker image [confluentinc/cp-kafka-connect](https://hub.docker.com/r/confluentinc/cp-kafka-connect/)

We start with an outline outline of how to configure the Connector to send data to Humio.
After the configuration section a longer example will follow showing how to get a Kafka connector installed and running.

{{% notice note %}}
***Authentication***

The Elasticsearch Connector does not yet support Basic Authentication. Because of that the connector cannot be used to send data to a Humio cluster setup with authentication.
There is a [pull request]( https://github.com/confluentinc/kafka-connect-elasticsearch/pull/187) to support authentication, and we are eagerly waiting for it to be accepted.
Contact us if you need this feature, we can add another way of authenticating against Humio (for example providing the authentication token in a request parameter)
{{% /notice %}}

## Configuring the kafka connector

### Worker.properties
The worker properties for the connector could look like below. It uses JSON for Serialization and does not use schemas.

``` properties
bootstrap.servers=$SERVER1:9092,$SERVER2:9092
offset.flush.interval.ms=1000

rest.port=10082
rest.host.name=$SERVER1
rest.advertised.port=10082
rest.advertised.host.name=$SERVER1

internal.key.converter=org.apache.kafka.connect.json.JsonConverter
internal.value.converter=org.apache.kafka.connect.json.JsonConverter
internal.key.converter.schemas.enable=false
internal.value.converter.schemas.enable=false

key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=false
value.converter.schemas.enable=false
value.converter.schemas.enable=false

plugin.path=/usr/share/java

# use below property when running the connector in standalone mode
#offset.storage.file.filename=/tmp/connect.offsets

# use below section when running the connector in distributed mode
group.id=humio-connector
config.storage.topic=humio-connect-configs
offset.storage.topic=humio-connect-offsets
status.storage.topic=humio-connect-statuses
config.storage.replication.factor=1
offset.storage.replication.factor=1
status.storage.replication.factor=1
```

The documentation for [Kafka Connect properties can be found  here](https://kafka.apache.org/documentation/#connectconfigs).  
Some of the above values, like `$SERVER1` needs to be replaced in the above configuration. Also the last section, describing replication factor etc should be configured to match your Kafka cluster and your requirements.
A replication factor of 1 is only put in the configuration file to make it work on a single node. the Elasticsearch Connector must be available in the `plugin.path`.



### Connector properties

The JSON with connector properties could look like below:

``` JSON
{
  "name": "humio-sink",
  "config" : {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "tasks.max": 1,
    "topics": "logs",
    "key.ignore": true,
    "schema.ignore": true,
    "behavior.on.malformed.documents": "warn",
    "drop.invalid.message": true,
    "connection.url": "http://$HUMIO_HOST:$HUMIO_PORT/api/v1/dataspaces/$DATASPACE/ingest/elasticsearch",
    "type.name": "kafka-ingest",
    "max.retries": 1000,
  }
}
```
The official documentation for the configuring the [Elasticsearch Connector is here](https://docs.confluent.io/current/connect/connect-elasticsearch/docs/configuration_options.html).  

`topics` specifies the topics data are read from. `connection.url` must point to the Humio ingest endpoint and specify a dataspace. In our experience setting `max.retries` high is important, as the connector will stop when reaching `max.retries` without success. The documentation [describes](https://docs.confluent.io/current/connect/connect-elasticsearch/docs/elasticsearch_connector.html#automatic-retries) how an exponential backup technique is used.
Also check out the documentation, for setting batch size, buffering, flushing etc.


## Performance and high availability

Kafka connectors are stateless, as their state is stored in Kafka. They work very much like [Kafkas Consumer groups](https://kafka.apache.org/documentation/#intro_consumers) and are scaled the same way. A topic/queue in Kafka can have multiple partitions, and it is possible to get as much parallelism as there are partitions. So multiple Connect workers can be deployed on multiple machines. At any time only one worker is reading from a partition. If a worker fails, other workers can take over. All this is handled by Kafka.


## Transforming data
Kafka connectors support [transforming data](https://kafka.apache.org/documentation/#connect_transforms)
This way it is possible (to some extend) to transform data before inserting it into Humio.


## At least once delivery semantics

The Elasticsearch Connector documents it guarantees exactly once delivery. This is not the case when used with Humio.
Elastcicsearch supports idempotent writes, if a document ID is supplied by the client. The Connector commits back to Kafka the highest offset for which events has been written successfully. In the case of failures, it restarts from the last committed offset. By supporting idempotent writes, exactly once semantics can be supported.
Humio is not designed like a traditionally database where you write a record with an ID, it is more of a append system and we do not support idempotent writes yet.
This is one of the features we plan to improve in Humio.

---
title: "Kafka Connect"
---

[Kafka Connect](https://kafka.apache.org/documentation/#connect) is a framework
for connecting Kafka with other systems such as Humio. If you have your data
in Kafka consider this approach for sending data to Humio.

As Humio supports ingesting data using the ElasticSearch bulk api, data can be send to Humio using the [ElasticSearch Connector](https://docs.confluent.io/current/connect/connect-elasticsearch/docs/elasticsearch_connector.html) by Confluent.

The Kafka Connect framework is part of the standard Kafka download but the Confluent ElasticSearch Connector must be downloaded separately. It is available in the Docker image [confluentinc/cp-kafka-connect](https://hub.docker.com/r/confluentinc/cp-kafka-connect/).

We start with an outline of how to configure the Connector to send data to Humio.
After the configuration section a longer example will follow showing how to get a Kafka connector installed and running.

{{% notice note %}}

***Authentication***

The ElasticSearch Connector does not yet support Basic Authentication.
Because of that the connector cannot be used to send data to a Humio
installation that's configured with authentication.
There is a [pull request]( https://github.com/confluentinc/kafka-connect-elasticsearch/pull/187)
to support authentication, and we are eagerly waiting for it to be accepted.
Contact us if you need this feature, we can add another way of authenticating against Humio.
{{% /notice %}}

## Configuring the kafka connector
<!-- Some intro about what to do with the following -->

This section shows how to configure the Kafka connector to send data to Humio.
Configuration is done in 2 parts. A `worker.properties` properties file and a
JSON request with the `connector properties` starting the connector.

### Worker.properties
The worker properties for the connector could look like below. It uses JSON for Serialization and does not use schemas.

```shell
bootstrap.servers=<Kafka server 1>:9092,<Kafka server 2>:9092,<Kafka server n>:9092
offset.flush.interval.ms=1000

rest.port=10082
rest.host.name=<hostname>

internal.key.converter=org.apache.kafka.connect.json.JsonConverter
internal.value.converter=org.apache.kafka.connect.json.JsonConverter
internal.key.converter.schemas.enable=false
internal.value.converter.schemas.enable=false

key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=false
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

All `<key>` placeholders in the above configuration example will have to be
replaced with concrete values. Also the last section, describing replication
factor etc., should be configured to match your Kafka cluster and your requirements.

A replication factor of 1 is only put in the configuration file to make it work
on a single node. the ElasticSearch Connector must be available in the `plugin.path`.

Please see the [Kafka Connect properties documentation](https://kafka.apache.org/documentation/#connectconfigs) for a detailed explanation of the properties.  

### Connector properties

The JSON with connector properties could look like below:

```json
{
  "name": "humio-sink",
  "config" : {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticSearchSinkConnector",
    "tasks.max": 1,
    "topics": "logs",
    "key.ignore": true,
    "schema.ignore": true,
    "behavior.on.malformed.documents": "warn",
    "drop.invalid.message": true,
    "connection.url": "http://$HOST:$PORT/api/v1/dataspaces/$REPOSITORY_NAME/ingest/elasticsearch",
    "type.name": "kafka-ingest",
    "max.retries": 1000
  }
}
```

`topics` specifies the topics data is read from. `connection.url` must point to
the Humio ingest endpoint and specify a repository. `connection.url` can be a
list of comma-separated urls, and supports load balancing.  

In our experience setting `max.retries` high is important, as the connector will
stop when reaching `max.retries` without success. The documentation [describes](https://docs.confluent.io/current/connect/connect-elasticsearch/docs/elasticsearch_connector.html#automatic-retries)
how an exponential backup technique is used. Also check out the documentation, for setting batch size, buffering, flushing etc.

Please refer to the [ElasticSearch Connector properties documentation](https://docs.confluent.io/current/connect/connect-elasticsearch/docs/configuration_options.html) for an explanation of the properties in the above example.  

## Performance and high availability

Kafka connectors are stateless, as their state is stored in Kafka. They work very much like [Kafka's Consumer groups](https://kafka.apache.org/documentation/#intro_consumers) and are scaled the same way. A topic/queue in Kafka can have multiple partitions, and it is possible to get as much parallelism as there are partitions. So multiple Connect workers can be deployed on multiple machines. At any time only one worker is reading from a partition. If a worker fails, other workers can take over. All this is handled by Kafka.

## Transforming data

<!--TODO: Some elaboration needed -->
Kafka connectors support [transforming data](https://kafka.apache.org/documentation/#connect_transforms)
This way it is possible (to some extend) to transform data before inserting it into Humio.

## At least once delivery semantics

The ElasticSearch Connector documents it guarantees exactly once delivery.
This is not the case when used with Humio.
ElasticSearch supports idempotent writes, if a document ID is supplied by the client.

The Connector commits back to Kafka the highest offset for which events has been
written successfully. In the case of failures, it restarts from the last committed offset.
By supporting idempotent writes, exactly once semantics can be supported.
Humio is not designed like a traditionally database where you write a record with an ID,
it is more of a append system and we do not support idempotent writes yet.
This is one of the features we plan to improve.

To minimize the problem, the interval between committing the offset can be set low. this is done using the [`offset.flush.interval.ms` configuration](https://kafka.apache.org/documentation/#connectconfigs).

## Example running a Connector sending data to Humio
In this example we assume Humio and Kafka are already running.
We will use the [confluentinc/cp-kafka-connect](https://hub.docker.com/r/confluentinc/cp-kafka-connect/) Docker image as it has the [Confluent ElasticSearch connector](https://docs.confluent.io/current/connect/connect-elasticsearch/docs/index.html) installed.

We start out by defining a `worker.properties` file:

```shell
# use below property when running in standalone mode
# offset.storage.file.filename=/tmp/connect.offsets

# use section when running in distributed
group.id=humio-connector
config.storage.topic=humio-connect-configs
offset.storage.topic=humio-connect-offsets
status.storage.topic=humio-connect-statuses
config.storage.replication.factor=1
offset.storage.replication.factor=1
status.storage.replication.factor=1

bootstrap.servers=kafka:9092
offset.flush.interval.ms=1000

rest.port=10082

internal.key.converter=org.apache.kafka.connect.json.JsonConverter
internal.value.converter=org.apache.kafka.connect.json.JsonConverter
internal.key.converter.schemas.enable=false
internal.value.converter.schemas.enable=false

key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=false
value.converter.schemas.enable=false

plugin.path=/usr/share/java
```

Start the Connector with the following command

```shell
docker run -it -d \
  -p 10082:10082 \
  --name=humio-kafka-connect \
  -v $(pwd):/config \
  --add-host kafka:$KAFKA_SERVER \
  confluentinc/cp-kafka-connect:4.1.1-2 connect-distributed /config/worker.properties
```

Replace `$KAFKA_SERVER` with the address of your one your kafka servers. <!--TODO: finish sentence from "and the above script will start tREST API for managing connectors on localhost port 10082."-->

<!--TODO: Reread this sentence--> If the Kafka topics to read data from does not already exist we need to create them. That can be done using the `kafka-topics` script in the  in the bin directory of the kafka installation. It is also possible to do using the
`humio-kafka-connect` Docker container we have just started to run our connector.

```shell
docker exec -it humio-kafka-connect kafka-topics \
  --zookeeper kafka:2181 \
  --create \
  --topic logs \
  --partitions 1 \
  --replication-factor 1
```

Above we created the topic `logs`. It can be replaced with the topic name you
want to use and you can change other configurations as well.

Now the ElasticSearch connector is ready to be started so first we will create
the JSON configuration (`humio-connect.json`):

```json
{
  "name": "humio-sink",
  "config" : {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticSearchSinkConnector",
    "tasks.max": 1,
    "topics": "$TOPICS",
    "key.ignore": true,
    "schema.ignore": true,
    "behavior.on.malformed.documents": "warn",
    "drop.invalid.message": true,
    "connection.url": "https://$HOST:443/api/v1/dataspaces/$REPOSITORY_NAME/ingest/elasticsearch",
    "type.name": "mytype",
    "max.retries": 1000
  }
}
```

{{< partial "common-rest-params.html" >}}
* `$TOPICS` should be replaced with a comma-separated list of topics to read data from.  
* `connection.url` takes a comma-separated list of URLs. In this example we use only one url.

Save the above JSON to a file named `humio-connect.json`.

Make sure Humio is running, otherwise the connector will fail during start up.
Now we can initiate the connector with the above configuration with the
following Curl commands:

```shell
curl -X POST -H "Content-Type: application/json" \
  --data-binary "@humio-connect.json" \
  http://localhost:10082/connectors
```

If you need to reconfigure, the connector can be removed using:

```shell
curl -XDELETE http://localhost:10082/connectors/humio-sink
```

Now we have all the different pieces running. We can add data to our Kafka
topic and check it is sent to Humio:

```shell
echo '{"@timestamp": "2018-06-03T20:53:23Z", "message": "hello world"}' \
 | docker exec -i  humio-kafka-connect kafka-console-producer \
                     --broker-list kafka:9092 \
                     --topic logs
```

Go to Humio and find the event in the repository you configured.
Remember to set the search time interval enough back in time to find the above event.

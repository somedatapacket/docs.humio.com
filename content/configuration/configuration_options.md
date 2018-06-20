---
title: "Configuration Options"
weight: 1
---

Humio is configured by setting environment variables.

**Docker Tip**  
When running Humio in Docker you can pass set the `--env-file=` flag and keep
your configuration in a file. For a quick intro to setting configuration options see the documentation for [installation on docker]({{< ref "docker.md" >}}).


## Example configuration file with comments {#example-configuration-file-with-comments}

```properties
# The stacksize should be at least 2M.
# We suggest setting MaxDirectMemory to 50% of physical memory. At least 2G required.
HUMIO_JVM_ARGS=-XX:+UseParallelOldGC -Xss2M -XX:MaxDirectMemorySize=4G

# Make Humio write a backup of the data files:
# Backup files are written to mount point "/backup".
#BACKUP_NAME=my-backup-name
#BACKUP_KEY=my-secret-key-used-for-encryption

# ID to choose for this server when starting up the first time.
# Leave commented out to autoselect the next available ID.
# If set, the server refuses to run unless the ID matches the state in data.
# If set, must be a (small) positive integer.
#BOOTSTRAP_HOST_ID=1

# The URL that other humio hosts in the cluster can use to reach this server.
# Required for clustering. Examples: https://humio01.example.com  or  http://humio01:8080
# Security: We recommend using a TLS endpoint.
# If all servers in the Humio cluster share a closed LAN, using those endpoints may be okay.
EXTERNAL_URL=https://humio01.example.com

# The URL which users/browsers will use to reach the server
# This URL is used to create links to the server
# It is important to set this property when using OAuth authentication or alerts
PUBLIC_URL=https://humio.mycompany.com

# Specify the replication factor for the Kafka ingest queue
#INGEST_QUEUE_REPLICATION_FACTOR=2

# Kafka bootstrap servers list. Used as `bootstrap.servers` towards kafka.
# should be set to a comma separated host:port pairs string.
# Example: `my-kafka01:9092` or `kafkahost01:9092,kafkahost02:9092`
KAFKA_SERVERS=kafkahost01:9092,kafkahost02:9092

# Zookeeper servers.
# Defaults to "localhost:2181", which is okay for a single server system, but
# should be set to a comma separated host:port pairs string.
# Example: zoohost01:2181,zoohost02:2181,zoohost03:2181
# Note, there is NO security on the zookeeper connections. Keep inside trusted LAN.
#ZOOKEEPER_URL=localhost:2181

# Select the TCP port to listen for http.
#HUMIO_PORT=8080
# Select the TCP port for ElasticSearch Bulk API
#ELASTIC_PORT=9200

# Select the IP to bind the udp/tcp/http listening sockets to.
# Each listener entity has a listen-configuration. This ENV is used when that is not set.
#HUMIO_SOCKET_BIND=0.0.0.0

# Select the IP to bind the http listening socket to. (Defaults to HUMIO_SOCKET_BIND)
#HUMIO_HTTP_BIND=0.0.0.0

# The URL where the Humio instance is reachable. (Leave our trailing slashes)
#
# This is important if you plan to use OAuth Federated Login or if you want to
# be able to have Alert Notifications have consistent links back to the Humio UI.
# The URL might only be reachable behind a VPN but that is no problem, as a
# browser can access it.
#PUBLIC_URL=https://demo.example.com/humio
```

## Java virtual machine parameters
You can specify Java virtual machine parameters to pass to Humio using the
property `HUMIO_JVM_ARGS`. The defaults are:

```properties
HUMIO_JVM_ARGS=-XX:+UseParallelOldGC -Xss2M -XX:MaxDirectMemorySize=4G
```

## Number of CPU Cores
You can specify the number of processors for the machine running Humio by
setting the `CORES` property. Humio uses this number when parallelizing queries.

By default, Humio uses the Java [available processors function](https://docs.oracle.com/javase/8/docs/api/java/lang/Runtime.html#availableProcessors--)
to get the number of CPU cores. This is usually the optimal number.

## Configuring Authentication

Humio supports different ways of authentication users. Read more in the
dedicated [Authentication Documentation]({{< relref "authentication.md" >}}).

## Public URL {#public_url}

`PUBLIC_URL` is the URL where the Humio instance is reachable from a browser.
Leave out trailing slashes.

This property is only important if you plan to use
[OAuth Federated Login]({{< relref "authentication.md#oauth">}}),
[Auth0 Login]({{< relref "authentication.md#auth0">}}) or if you want to be able
to have Alert Notifications have consistent links back to the Humio UI.

The URL might only be reachable behind a VPN but that is no problem, as the user's
browser can access it.

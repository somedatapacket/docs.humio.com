---
title: "Configuration"
category_title: Overview
weight: 700
---

Humio is configured by setting environment variables. The example configuration
file below contains comments describing each individual option.

**Docker Tip**  
When running Humio in Docker you can pass set the `--env-file=` flag and keep
your configuration in a file. For a quick intro to setting configuration options
see the documentation for [installation on docker]({{< ref "docker.md" >}}).

## Example configuration {#example-configuration-file-with-comments}

```properties
# The stacksize should be at least 2M.
HUMIO_JVM_ARGS=-XX:+UseParallelOldGC -Xss2M

# Make Humio write a backup of the data files:
# Backup files are written to mount point "/backup".
BACKUP_NAME=my-backup-name
BACKUP_KEY=my-secret-key-used-for-encryption

# ID to choose for this server when starting up the first time.
# Leave commented out to autoselect the next available ID.
# If set, the server refuses to run unless the ID matches the state in data.
# If set, must be a (small) positive integer.
BOOTSTRAP_HOST_ID=1

# The URL that other humio hosts in the cluster can use to reach this server.
# Required for clustering. Examples: https://humio01.example.com  or  http://humio01:8080
# Security: We recommend using a TLS endpoint.
# If all servers in the Humio cluster share a closed LAN, using those endpoints may be okay.
EXTERNAL_URL=https://humio01.example.com

# The URL which users/browsers will use to reach the server
# This URL is used to create links to the server
# It is important to set this property when using OAuth authentication or alerts.
PUBLIC_URL=https://humio.mycompany.com

## For how long should dashboard queries be kept running if they are not polled.
## When opening a dashboard, results will be immediately ready if queries are running.
## Default is 3 days 
IDLE_POLL_TIME_BEFORE_DASHBOARD_QUERY_IS_CANCELLED_MINUTES=4320

# Specify the replication factor for the Kafka ingest queue
INGEST_QUEUE_REPLICATION_FACTOR=2

# Kafka bootstrap servers list. Used as `bootstrap.servers` towards kafka.
# should be set to a comma separated host:port pairs string.
# Example: `my-kafka01:9092` or `kafkahost01:9092,kafkahost02:9092`
KAFKA_SERVERS=kafkahost01:9092,kafkahost02:9092

# By default Humio will create topics and manage number of replica in Kafka for the topics being used.
# If you run Humio on top of an existing Kafka or want to manage this outside of Humio, set this to false.
KAFKA_MANAGED_BY_HUMIO=true

# It is possible to add extra Kafka configuration properties. by creating a properties file and pointing to it.
# These properties are added to all Kafka producers and consumers in Humio.
# For example, this enables Humio to connect to a Kafka cluster using SSL and SASL.
# Note the file must be mapped into Humio's Docker container - if running Humio as a Docker container
EXTRA_KAFKA_CONFIGS_FILE=extra_kafka_properties.properties

# Zookeeper servers.
# Defaults to "localhost:2181", which is okay for a single server system, but
# should be set to a comma separated host:port pairs string.
# Example: zoohost01:2181,zoohost02:2181,zoohost03:2181
# Note, there is NO security on the zookeeper connections. Keep inside trusted LAN.
ZOOKEEPER_URL=localhost:2181

# Maximum number of datasources (unique tag combinations) in a repo.
# There will be a sub-directory for each combination that exists.
# (Since v1.1.10)
MAX_DATASOURCES=10000

# Compresions level for data in segment files. Defaults to 9, range is [1 ; 17]
 COMPRESSION_LEVEL=9

# (Approximate) limit on the number of hours a segment file can be open for writing
# before being flushed even if it is not full.
MAX_HOURS_SEGMENT_OPEN=720

# Let Humio send emails using the Postmark service
# Create a Postmark account and insert the token here
POSTMARK_SERVER_SECRET=abc2454232

# Let Humio send emails using an SMTP server. ONLY put a password here
# if you also enable starttls. Otherwise you will expose your password.
#
# Example using GMail:
#SMTP_HOST=smtp.gmail.com
#SMTP_PORT=587
#SMTP_SENDER_ADDRESS=you@domain.com
#SMTP_USE_STARTTLS=true
#SMTP_USERNAME=you@domain.com
#SMTP_PASSWORD=your-secret-password
#
# Example using a local clear-text non-authenticated SMTP server
SMTP_HOST=localhost
SMTP_PORT=25
SMTP_SENDER_ADDRESS=you@domain.com
SMTP_USE_STARTTLS=false


# Use a HTTP proxy for sending alert notifications
# This can be usefull if Humio is not allowed direct access to the internet
#
HTTP_PROXY_HOST=proxy.myorganisation.com
HTTP_PROXY_PORT=3129
HTTP_PROXY_USERNAME=you
HTTP_PROXY_PASSWORD=your-secret-password

# Select the TCP port to listen for http.
HUMIO_PORT=8080
# Select the TCP port for ElasticSearch Bulk API
ELASTIC_PORT=9200

# Select the IP to bind the udp/tcp/http listening sockets to.
# Each listener entity has a listen-configuration. This ENV is used when that is not set.
HUMIO_SOCKET_BIND=0.0.0.0

# Select the IP to bind the http listening socket to. (Defaults to HUMIO_SOCKET_BIND)
HUMIO_HTTP_BIND=0.0.0.0

# Verify checksum of segments files when reading them. Default to true. Allows detecting partial and malformed files.
# (Since v1.1.16)
#VERIFY_CRC32_ON_SEGMENT_FILES=true

# S3 access keys for archiving of ingested logs
S3_ARCHIVING_ACCESSKEY=$ACCESS_KEY
S3_ARCHIVING_SECRETKEY=$SECRET_KEY

# Users need to be created in Humio before they can login with external authentication methods like SAML/LDAP/OAUTH etc.
# set this parameter to true - then users are automatically created in Humio when successfully logging with external authentication methods.
# Users will not have access to any existing repositories except for a personal sandbox repository when they are created.
# if false - users must be explicitly created in Humio before they can login.
AUTO_CREATE_USER_ON_SUCCESSFULL_LOGIN=false

# Initial partition count for storage partitions.
# Has effect ONLY on first start of first node in the cluster.
DEFAULT_PARTITION_COUNT=24

# Initial partition count for digest partitions.
# Has effect ONLY on first start of first node in the cluster.
INGEST_QUEUE_INITIAL_PARTITIONS=24


# How big a backlog of events in Humio is allowed before Humio starts responding
# http-status=503 on the http interfaces and reject ingesting messages on http?
# Measured in seconds worth of latency from an event arrive at Humio until it has
# been fully processed.
# (Note that typical latency in normal conditions is is zero to one second.)
# Set to a large number, such as 31104000 (~1 year as seconds) to avoid
# having this kind of back pressure towards the ingest clients.
# Range: Min=300, Max=2147483647.
MAX_INGEST_DELAY_SECONDS=3600


# A configuration flag to limit state in Humio searches. 
# For example this is used to limit the number of groups in the groupBy function.
# This is necessary to limit how much memory searches can use and avoid out of memory etc. 
MAX_STATE_LIMIT=20000


# SECONDARY_DATA_DIRECTORY enables using a secondary file system to
# store segment files. When to move the files is controlled by
# PRIMARY_STORAGE_PERCENTAGE
# Secondary storage is not enabled by default.
# Note! When using docker, make sure to mount the volume
# into the container as well.
# See the page on "Secondary storage" for more information.
SECONDARY_DATA_DIRECTORY=/secondaryMountPoint/humio-data2
PRIMARY_STORAGE_PERCENTAGE=80


# Humio will write threaddumps to humio-threaddumps.log with the interval specified here
# If not specified Humio will write threaddumps every 10 seconds
DUMP_THREADS_SECONDS=10

```

## Java virtual machine parameters
You can specify Java virtual machine parameters to pass to Humio using the
property `HUMIO_JVM_ARGS`. The defaults are:

```properties
HUMIO_JVM_ARGS=-XX:+UseParallelOldGC -Xss2M
```

## Number of CPU Cores
You can specify the number of processors for the machine running Humio by
setting the `CORES` property. Humio uses this number when parallelizing queries.

By default, Humio uses the Java [available processors function](https://docs.oracle.com/javase/9/docs/api/java/lang/Runtime.html#availableProcessors--)
to get the number of CPU cores. This is usually the optimal number.

## Configuring Authentication

Humio supports different ways of authentication users. Read more in the
dedicated [Authentication Documentation]({{< ref "configuration/authentication/_index.md" >}}).

## Public URL {#public_url}

`PUBLIC_URL` is the URL where the Humio instance is reachable from a browser.
Leave out trailing slashes.

This property is only important if you plan to use
[OAuth Federated Login]({{< ref "oauth.md">}}),
[Auth0 Login]({{< ref "auth0.md">}}) or if you want to be able
to have Alert Notifications have consistent links back to the Humio UI.

The URL might only be reachable behind a VPN but that is no problem, as the user's
browser can access it.

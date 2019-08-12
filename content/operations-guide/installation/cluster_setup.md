---
title: "Cluster Setup"
weight: 1000
aliases: ["/operation/installation/cluster_setup/", "installation/cluster_setup"]
---

This section describes how to install Humio configured as a distributed system across multiple machines.

## Prerequisites

Running a distributed Humio setup requires a Kafka cluster (version 1.0).
You can setup such a cluster using our Docker image. Or you can install Kafka using some other method.

<!--
TODO: This page should be about HOW things fit together, not the docker containers. 	                                         
Leave that to the `docker.md` page

The configuration options needed and software that should be installed should be
described here.
 -->

### Installation and configuration scripts

We have created a [Github repository](https://github.com/humio/provision-humio-cluster) with scripts to help install and configure Humio.
We suggest you read through the documentation below and have a look at repository. Check out the scripts and modify them for your environment.

You should also look at the [reference Ansible project](https://github.com/humio/ansible-demo)
for an example of this in practice.

### Running the Zookeeper and Kafka Docker images

The recommended default is to run 3 instances of the Zookeeper and Kafka with our Docker images.
The Zookeeper and Kafka instances must run on ports, that the Humio instances can connect to.
The suggested setup below maps the user "Humio" on the host machine to the user "Humio" inside the Docker containers
and runs the Zookeeper, Kafka, and Humio processes as that user. This allows the processes to write to the mounted data directories.
Tailor according to your needs and make sure the `/data/` directories are on a mount point with sufficient storage. (e.g. probably not `/`).

The data is split on 4 mounting points, in the example configurations below on these prefixes:

1. `/data/logs` holds log files from the various processes.
2. `/data/zookeeper-data` holds zookeeper data. (Not much)
3. `/data/kafka-data` holds Kafka data.
4. `/data/humio-data` holds Humio data.

The following shows how to use the `humio/humio-kafka` image to set up
Zookeeper and Kafka in a 3 machine cluster.

For each machine do:

1. Ensure the `humio` user exists

    ```shell
    $ adduser --disabled-password --disabled-login humio
    ```

2. Add the `humio` user to `docker` group to run Docker without root privileges. (humio user should not have sudo access)

    ```shell
    $ usermod -aG docker humio
    ```

3. Create a data directory for Zookeeper

    ```shell
    $ mkdir -p /data/logs
    $ chown -R humio:humio /data/logs
    $ mkdir -p /data/zookeeper-data
    $ chown -R humio:humio /data/zookeeper-data
    ```

4. Create a configuration file for Zookeeper. Replace the `HOST_1-3` variables with the DNS name or IP addresses of your hosts; here is the configuration file for `HOST`. Save it a known location, such as `/etc/humio/zookeeper.properties`

    ```properties
    dataDir=/data/zookeeper-data
    clientPort=2181
    clientPortAddress=${HOST}
    tickTime=2000
    initLimit=5
    syncLimit=2
    server.1=${HOST_1}:2888:3888
    server.2=${HOST_2}:2888:3888
    server.3=${HOST_3}:2888:3888
    ```

5. Set the `myid` file the ID of the given server as specified in the configuration file above (`1`, `2` or `3`), i.e.

    ```shell
    $ echo 1 > /data/zookeeper-data/myid
    $ chown humio:humio /data/zookeeper-data/myid
    ```

6. Create a data directory for Kafka

    ```shell
    $ mkdir -p /data/kafka-data
    $ chown -R humio:humio /data/kafka-data
    ```
{{% notice info %}}
Make sure Kafka's mount point is on a separate volume from the others. Kafka is notorious for
consuming large amounts of disk space, so it's important to protect the other services from
running out of disk by using a separate volume in production deployments.
Make sure all volumes are being appropriately monitored as well. If your installation does
run out of disk space and gets into a bad state, you can find recovery instructions [here]({{< ref "../administration/kafka-switch.md" >}}).
{{% /notice %}}

7. Create a configuration file for Kafka. Each server needs to have a unique name and an `broker.id`  (`1`, `2` or `3`). Make sure the listener is something the humio instances can reach. If in doubt, please refer to the Kafka documentation. Here is the configuration file for `HOST`, remember to set `broker.id` and `listeners` accordingly. Save it a known location, such as `/etc/humio/kafka.properties`

    ```properties
    broker.id=1
    log.dirs=/data/kafka-data
    zookeeper.connect=${HOST_1}:2181,${HOST_2}:2181,${HOST_3}:2181
    listeners=PLAINTEXT://${HOST}:9092
    replica.fetch.max.bytes=104857600
    message.max.bytes=104857600
    compression.type=producer
    num.partitions=1
    log.retention.hours=48
    log.retention.check.interval.ms=300000
    unclean.leader.election.enable=false
    broker.id.generation.enable=false
    auto.create.topics.enable=false
    ```


8. [Install Docker](https://docs.docker.com/engine/installation/) and pull the latest `humio/zookeeper` and `humio/kafka` Docker images

    ```shell
    $ docker pull humio/zookeeper
    $ docker pull humio/kafka
    ```

9. Start the Docker images on each host, mounting the configuration files and data locations created in previous steps

    ```shell
    $ docker run -d  --restart always --net=host \
      -v /etc/humio/zookeeper.properties:/etc/kafka/zookeeper.properties \
      -v /data/logs:/products/kafka/logs \
      -v /data/zookeeper-data:/data/zookeeper-data  \
      --name humio-zookeeper "humio/zookeeper"
    $ docker run -d  --restart always --net=host \
      -v /etc/humio/kafka.properties:/etc/kafka/kafka.properties \
      -v /data/logs:/products/kafka/logs \
      -v /data/kafka-data:/data/kafka-data  \
      --name humio-kafka "humio/kafka"
    ```

### Verify that Zookeeper and Kafka are happy

1. Inspecting the log files:

    - `$ docker logs humio-zookeeper`
    - `$ docker logs humio-kafka`

2. Using "nc" to get the status of each zookeeper instance. The following must respond with either "Leader" or "Follower" for all instances:

    ```shell
    $ echo stat | nc 192.168.1.1 2181 | grep '^Mode: '
    ```

3. Optionally, using your favourite Kafka tools to validate the state of your Kafka cluster. You could list the topics using this, expecting to get an empty list since this is a fresh install of Kafka

    ```shell
    $ kafka-topics.sh --zookeeper localhost:2181 --list
    ```

## Running the Humio Docker container {#running-humio}

Humio is distributed as Docker images; use the `humio/humio-core` edition for distributed deployments.

### Steps

1. Create an empty file on the host machine to store the Humio configuration. For example, `humio.conf`.

    You can use this file to pass on JVM arguments to the Humio Java process.

2. Enter and then edit the following settings into the configuration file:

    ```properties
    # The stacksize should be at least 2M.
    HUMIO_JVM_ARGS=-Xss2M

    # Make Humio write a backup of the data files:
    # Backup files are written to mount point "/backup".
    #BACKUP_NAME=my-backup-name
    #BACKUP_KEY=my-secret-key-used-for-encryption

    # ID to choose for this server when starting up the first time.
    # Leave commented out to autoselect the next available ID.
    # If set, the server refuses to run unless the ID matches the state in data.
    # If set, must be a (small) positive integer.
    #BOOTSTRAP_HOST_ID=1

    # The URL that other hosts can use to reach this server. Required.
    # Examples: https://humio01.example.com  or  http://humio01:8080
    # Security: We recommend using a TLS endpoint.
    # If all servers in the Humio cluster share a closed LAN, using those endpoints may be okay.
    EXTERNAL_URL=https://humio01.example.com

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

    # Select the IP to bind the udp/tcp/http listening sockets to.
    # Each listener entity has a listen-configuration. This ENV is used when that is not set.
    #HUMIO_SOCKET_BIND=0.0.0.0

    # Select the IP to bind the http listening socket to. (Defaults to HUMIO_SOCKET_BIND)
    #HUMIO_HTTP_BIND=0.0.0.0
    ```
{{% notice info %}}
Docker only loads the environment file **when the container is initially created**.
As such, if you make changes to the settings in your environment file, simply
stopping and starting the container will not work. You need to `docker rm` the
container and `docker run` it again to pick up changes.
{{% /notice %}}

3. Create an empty directory on the host machine to store data for Humio:

    ```shell
    $ mkdir /data/humio-data
    ```

4. Pull the latest Humio image:

    ```shell
    $ docker pull humio/humio-core
    ```

5. Run the Humio Docker image as a container:

    ```shell
    $ docker run -d  --restart always --net=host \
      -v /data/logs:/data/logs \
      -v /data/humio-data:/data/humio-data \
      -v /backup:/backup  \
      --env-file $PATH_TO_CONFIG_FILE --name humio-core humio/humio-core
    ```

    Replace `/data/humio-data` before the `:` with the path to the humio-data directory you created on the host machine, and `$PATH_TO_CONFIG_FILE` with the path of the configuration file you created.

6. Verify that Humio is able to start using the configuration provided by looking at the log file.
   In particular, it should *not* keep on logging problems connecting to Kafka.

    ```shell
    $ grep 'Humio server is now running!'  /data/logs/humio_std_out.log
    $ grep -i 'kafka'  /data/logs/humio_std_out.log
    ```

7. Humio is now running. Navigate to [http://localhost:8080](http://localhost:8080) to view the Humio web interface.

{{% notice info %}}
In the above example, we started the Humio container with full access to the
network of the host machine. In a production environment, you should restrict
this access by using a firewall, or adjusting the Docker network configuration.
{{% /notice %}}


### Starting Humio as a service

There are different ways of starting the docker container
["as a service"](https://docs.docker.com/config/containers/start-containers-automatically/).
In the above example, we used Dockers
[restart policies](https://docs.docker.com/config/containers/start-containers-automatically#use-a-restart-policy).
It can be started using a process manager.


## Configuring Humio
Please refer to the [configuration]({{< ref "configuration/_index.md" >}}) section

## Cluster Management API
Please refer to the [API page]({{< ref "cluster-management-api.md" >}})

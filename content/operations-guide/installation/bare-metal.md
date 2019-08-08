---
Title: Single Server Bare Metal Installation
slug: installation-on-bare-metal
weight: 500
aliases: ["/installation/bare-metal"]
---

## Introduction

This document shows you how to install Humio alongside Java, Zookeeper, and Kafka on a single Ubuntu Server 16.04 or later LTS node.

Please note that Humio does not recommend this configuration for production purposes. Production environments should be clustered for failover and redundancy purposes. This set up is only provided for learning purposes and for proofs of concept. Single server and multi-server installations do have differences in their set up. 

For multi-server installations, please see [this cluster setup guide](cluster_setup).

## Hardware Requirements

Your single server Humio installation requires a minimum of:

* 16 CPU cores
* 16 GB of memory
* 1 GBit Network card

Disk space depends on the amount of ingested data per day and the number of retention days.

_Retention days x GB injected / compression factor = needed disk space for a single server_

For more information on retention in Humio, see [configuring data retention]({{< ref "retention.md" >}}). For more information on compression in Humio, see [index sizing]({{< ref "../../appendix/instance-sizing/" >}}).

On AWS, for a single server, start with Ubuntu M5.4XL. This instance type contains 16 vCPUs, 64 GB memory, up to 10 Gbps network).

## Network Requirements

In addition to port 22 (required to SSH into the server) the Humio node requires port 8080 opened to incoming traffic to service requests to the web application and API. If the new node is to be part of a cluster it will need to have the following incoming ports open:

|Application|Protocol|Port|
|---|---|---|
|Humio|TCP|8080, 9200|

{{% notice note %}}Port 9200 is optional.{{% /notice %}}

## System Requirements

Humio version 1.5.x requires:

- Java Virtual Machine 11+
- Zookeeper 3.4.X+ (recommended)
- Kafka 2.2+ (recommended)

Supported operating systems:
- Ubuntu 16.04 and higher
- RHEL 7

## Software Setup

{{% notice note %}}Where ‘x’ is used in filenames below, replace ‘x’ with the correct version number for the software you are installing.{{% /notice %}}

Confirm your Ubuntu version:

```
$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description: Ubuntu 16.04.2 LTS
Release: 16.04
Codename: bionic
```
{{% notice note %}}Humio will not install correctly on Ubuntu versions earlier than 16.04.{{% /notice %}}

As most of the following commands require root access, run sudo:
```
$ sudo -i
```
Before installing Zookeeper, Kafka, and Humio, update the system:

```
# apt-get update
# apt-get upgrade
```

Create non-administrative users (`humio, zookeeper, kafka`) to run Humio, Zookeeper, and Kakfa. The humio account owns the Humio files and directories: 

```
# adduser humio --shell=/bin/false --no-create-home --system --group

Adding system user `humio' (UID 112) ...
Adding new group `humio' (GID 116) ...
Adding new user `humio' (UID 112) with group `humio' ...
Not creating home directory `/home/humio'.
...

# adduser zookeeper --shell=/bin/false --no-create-home --system --group
# adduser kafka --shell=/bin/false --no-create-home --system --group
```

{{% notice note %}}We recommend adding these three users to the DenyUsers section of your node’s `/etc/ssh/sshd_config` file to prevent them from being able to ssh or sftp into the node, and remember to restart the sshd daemon after making the change.

Once the system has finished updating and the users are created, you can begin installing and configuring the required components.{{% /notice %}}

### Installing the JVM

Humio is a Scala-based application that requires a JVM version 11 or higher.

Humio recommends using Azul’s JVM, as it is used for Humio Cloud, and so it is well-tested for compatibility.

For more information on selecting and configuring the JVM, see [JVM configuration]({{< ref "../configuration/basic-configuration/jvm-configuration/" >}}).

1. Import Azul’s public key:
    ```
    # apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9

    Executing: /tmp/apt-key-gpghome.zaOdWfaSe2/gpg.1.sh --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
    gpg: key B1998361219BD9C9: public key "Azul Systems, Inc. (Package signing key.) <pki-signing@azulsystems.com>" imported
    gpg: Total number processed: 1
    gpg: imported: 1
    ```

2. Add the Azul package to the apt repo:
    ```
    # apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main'

    Hit:1 http://us-east-2.ec2.archive.ubuntu.com/ubuntu bionic InRelease
    Hit:2 http://us-east-2.ec2.archive.ubuntu.com/ubuntu bionic-updates InRelease
    ...
    Get:8 http://repos.azulsystems.com/ubuntu stable/main amd64 Packages [17.0 kB]
    Fetched 26.4 kB in 0s (55.5 kB/s)
    Reading package lists... Done
    ```
3. Update apt: 
   ```
    # apt-get update

    Hit:1 http://us-east-2.ec2.archive.ubuntu.com/ubuntu bionic InRelease
    Hit:2 http://us-east-2.ec2.archive.ubuntu.com/ubuntu bionic-updates InRelease
    Get:11 http://security.ubuntu.com/ubuntu bionic-security/universe amd64 	Packages [568 kB]
    Fetched 1347 kB in 2s (890 kB/s)
    Reading package lists... Done
    ```
4. Install version 11 or higher of Azul’s Zulu JVM. 

    {{% notice note %}}Update the command to reflect the release desired, replacing the `x` with the version number.{{% /notice %}}

    ```
    # apt-get install zulu-x

    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    The following additional packages will be installed:
    fontconfig-config fonts-dejavu-core java-common libasound2 libasound2-data libfontconfig1 libxi6 libxrender1 libxtst6 x11-common
    Suggested packages:
    default-jre libasound2-plugins alsa-utils
    The following NEW packages will be installed:
    fontconfig-config fonts-dejavu-core java-common libasound2 libasound2-data libfontconfig1 libxi6 libxrender1 libxtst6 x11-common zulu-11
    0 upgraded, 11 newly installed, 0 to remove and 3 not upgraded.
    Need to get 198 MB of archives.
    After this operation, 331 MB of additional disk space will be used.
    Do you want to continue? [Y/n]
    Get:1 http://us-east-2.ec2.archive.ubuntu.com/ubuntu bionic/main amd64 fonts-dejavu-core all 2.37-1 [1041 kB]
    ...
    update-alternatives: using /usr/lib/jvm/zulu-11-amd64/bin/rmic to provide 	/usr/bin/rmic (rmic) in auto mode
    update-alternatives: using /usr/lib/jvm/zulu-11-amd64/bin/serialver to provide /usr/bin/serialver (serialver) in auto mode
    Processing triggers for libc-bin (2.27-3ubuntu1) ...
    Processing triggers for ureadahead (0.100.0-21) ...
    Processing triggers for systemd (237-3ubuntu10.22) ...
    ```
    You can confirm that the JVM is installed using:
    ```
    # java --version

    openjdk 11.0.3 2019-04-16 LTS
    OpenJDK Runtime Environment Zulu11.31+11-CA (build 11.0.3+7-LTS)
    OpenJDK 64-Bit Server VM Zulu11.31+11-CA (build 11.0.3+7-LTS, mixed mode)
    ```
### Installing Zookeeper

Humio uses Kafka to buffer ingest and sequence events among the nodes of a Humio cluster. Kafka requires Zookeeper for coordination. To install Zookeeper:

1. Navigate to `opt` directory: 
    ```
    # cd /opt
    ```
2. Download the latest release of Zookeeper: 
    ```
    # wget http://us.mirrors.quenda.co/apache/zookeeper/zookeeper-x.x.x/zookeeper-x.x.x.tar.gz
    ```
3. Untar the Zookeeper file:
    ```
    # tar -zxf zookeeper-x.x.x.tar.gz
    ```
4. Create a symbolic to `/opt/zookeeper`:
    ```
    # ln -s /opt/zookeeper-x.x.x /opt/zookeeper
    ```
5. Navigate to `/opt/zookeeper` directory: 
    ```
    # cd /opt/zookeeper
    ```
6. Create a `data` directory for Zookeeper:
    ```
    # mkdir /var/zookeeper/data
    ```
7. Create the `zoo.cfg` file: 
    ```
    # nano conf/zoo.cfg
    ```
8. Fill in the configuration with the following details:
    ```
    tickTime = 2000
    dataDir = /var/zookeeper/data
    clientPort = 2181
    initLimit = 5
    syncLimit = 2
    maxClientCnxns=60
    server.1=127.0.0.1:2888:3888
    ```
9. Create the `myid` file in the `/var/zookeeper/data` directory. It will have the number `1` as its contents:
    ```
    # bash -c 'echo 1 > /var/zookeeper/data/myid'
    ```
10. Start Zookeeper to verify that the configuration is working:
    ```
    # ./bin/zkServer.sh start

    ZooKeeper JMX enabled by default
    Using config: /opt/zookeeper-x.x.x/bin/../conf/zoo.cfg
    Starting zookeeper ... STARTED
    ```
11. Verify that Zookeeper is running by logging in through the command line interface: 
    ```
    # ./bin/zkCli.sh
    Connecting to localhost:2181
    2019-06-20 20:56:52,767 [myid:] - INFO [main:Environment@100] - Client
    ...
    2019-06-20 20:56:52,822 [myid:] - INFO [main-SendThread(localhost:2181):ClientCnxn$SendThread@1299] - Session establishment complete on server localhost/127.0.0.1:2181, sessionid = 0x10000f560b50000, negotiated timeout = 30000
    WATCHER::
    WatchedEvent state:SyncConnected type:None path:null
    [zk: localhost:2181(CONNECTED) 0]
    ```
    Exit out using ctrl-c once the status is reported as connected.
12. Stop Zookeeper to complete the configuration:
    ```
    # ./bin/zkServer.sh stop
    ZooKeeper JMX enabled by default
    Using config: /opt/zookeeper-x.x.x/bin/../conf/zoo.cfg
    Stopping zookeeper ... STOPPED
    ```
13. Change the owner to the Zookeeper user:
    ```
    # chown -R zookeeper:zookeeper /opt/zookeeper-x.x.x
    ```
    {{% notice note %}}Changing the ownership of the link `/opt/zookeeper` does not change the ownership of the files in the directory.{{% /notice %}}

14. Create a Zookeeper service file:
    ```
    # nano /etc/systemd/system/zookeeper.service
    ```
15. Add the following to the zookeeper.service file:
    ```
    [Unit]
    Description=Zookeeper Daemon
    Documentation=http://zookeeper.apache.org
    Requires=network.target
    After=network.target
    
    [Service]
    Type=forking
    WorkingDirectory=/opt/zookeeper
    User=zookeeper
    Group=zookeeper
    ExecStart=/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
    ExecStop=/opt/zookeeper/bin/zkServer.sh stop /opt/zookeeper/conf/zoo.cfg
    ExecReload=/opt/zookeeper/bin/zkServer.sh restart /opt/zookeeper/conf/zoo.cfg
    TimeoutSec=30
    Restart=on-failure
    
    [Install]
    WantedBy=default.target
    ```
16. Start the Zookeeper service:
    ```
    # systemctl start zookeeper
    ```
17. Ensure the Zookeeper server started (press `q` to exit when finished reviewing log):
    ```
    # systemctl status zookeeper
    ● zookeeper.service - Zookeeper Daemon  
    Loaded: loaded (/etc/systemd/system/zookeeper.service; disabled; vendor preset: enabled)
    Active: active (running) since Thu 2019-07-25 02:25:44 UTC; 13s ago
    Docs: http://zookeeper.apache.org
    Process: 20865 ExecStart=/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg (code=exited, status=0/SUCCESS)
    Main PID: 20876 (java)
    Tasks: 22
    Memory: 38.7M
    CPU: 779ms
    CGroup: /system.slice/zookeeper.service
    └─20876 java -Dzookeeper.log.dir=. -Dzookeeper.root.logger=INFO,CONSOLE -cp /opt/zookeeper/bin/../zookeeper-server/target/class
    Jul 25 02:25:43 ip-172-31-0-166 systemd[1]: Starting Zookeeper Daemon...
    Jul 25 02:25:43 ip-172-31-0-166 zkServer.sh[20865]: ZooKeeper JMX enabled by default
    Jul 25 02:25:43 ip-172-31-0-166 zkServer.sh[20865]: Using config: /opt/zookeeper/conf/zoo.cfg
    Jul 25 02:25:44 ip-172-31-0-166 systemd[1]: Started Zookeeper Daemon.
    ```
18. Set the Zookeeper service to start on boot:
    ```
    # systemctl enable zookeeper
    ```

### Installing Kafka

1. Download the latest release:
    ```
    # cd /opt
    # wget https://www-us.apache.org/dist/kafka/x.x.x/kafka_x.x.x.x.tgz
    ```
2. Untar the downloaded file:
    ```
    # tar zxf kafka_x.x.x.x.tgz
    ```
3. Create a Kafka log directory:
    ```
    # mkdir /var/log/kafka
    ```
4. Give the `kafka` user ownership of the `/var/log/kafka/` directory:
    ```
    # chown kafka:kafka /var/log/kafka
    ```
5. Create a symbolic to `/opt/kafka:`
    ```
    # ln -s /opt/kafka_x.x.x.x /opt/kafka
    ```
6. Open the Kafka properties file:
    ```
    # nano kafka/config/server.properties
    ```
7. Set the `broker.id` value to match the server number (`myid`) you set when configuring Zookeeper:
    ```
    broker.id=1
    ```
8. Add the following line at the end of the `server.properties` file:
    ```
    delete.topic.enable = true
    ```
9. Change the owner to the kafka user:
    ```
    # chown -R kafka:kafka /opt/kafka_x.x.x.x
    ```
   {{% notice note %}}Changing the ownership of the link `/opt/kafka` does not change the ownership of the files in the directory.{{% /notice %}}
    
10. Create a Kafka service file:
    ```
    # nano /etc/systemd/system/kafka.service
    ```
11. Add the following content to the service file:
    ```
    [Unit]
    Requires=zookeeper.service
    After=zookeeper.service
    
    [Service]
    Type=simple
    User=kafka
    LimitNOFILE=800000
    Environment="LOG_DIR=/var/log/kafka"
    Environment="GC_LOG_ENABLED=true"
    Environment="KAFKA_HEAP_OPTS=-Xms512M -Xmx4G"
    ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
    Restart=on-failure
    
    [Install]
    WantedBy=multi-user.target
    ```
12. Start the Kafka service:
    ```
    # systemctl start kafka
    ```
13. Ensure the Kafka server started (press `q` to exit when finished reviewing log):
    ```
    # systemctl status kafka
    
    kafka.service
    Loaded: loaded (/etc/systemd/system/kafka.service; disabled; vendor preset: enabled)
    Active: active (running) since Thu 2019-07-18 21:21:16 UTC; 1min 8s ago
    Main PID: 11752 (java)
    Tasks: 67 (limit: 4915)
    CGroup: /system.slice/kafka.service
    └─11752 java -Xms512M -Xmx4G -server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -Djava.awt.headless=true -Xlog:gc*:file=
    ...
    Jul 18 21:21:18 ip-172-31-7-168 kafka-server-start.sh[11752]: [2019-07-18 21:21:18,514] INFO [TransactionCoordinator id=1] Startup complete. (kafka.coordinator.transaction.TransactionCoordinator)
    ...
    ```
14. Set Kafka to start on boot:
    ```
    # systemctl enable kafka
    ```

### Installing Humio

The following instructions cover the installation of Humio:

1. Create the Humio system directories and give the `humio` user ownership:
    ```
    # mkdir -p /opt/humio /etc/humio/filebeat /var/log/humio /var/humio/data
    ```
2. Navigate to `/opt/humio/`:
    ```
    # cd /opt/humio/
    ```
3. Download latest release from [https://repo.humio.com/service/rest/repository/browse/maven-releases/com/humio/server/](https://repo.humio.com/service/rest/repository/browse/maven-releases/com/humio/server/):
    ```
    # wget https://repo.humio.com/repository/maven-releases/com/humio/server/x.x.x/server-x.x.x.jar
    ```
4. Create a link to `server.jar`:
    ```
    # ln -s /opt/humio/server-x.x.x.jar /opt/humio/server.jar
    ```
5. Create the Humio configuration file:
    ```
    # nano /etc/humio/server.conf
    ```
6. Fill in the following contents, updating with DNS names or IP addresses where appropriate:
    ```
    BOOTSTRAP_HOST_ID=1
    DIRECTORY=/var/humio/data
    HUMIO_AUDITLOG_DIR=/var/log/humio
    HUMIO_DEBUGLOG_DIR=/var/log/humio
    HUMIO_PORT=8080
    ELASTIC_PORT=9200
    ZOOKEEPER_URL=127.0.0.01:2181
    KAFKA_SERVERS=127.0.0.1:9092
    EXTERNAL_URL=http://127.0.0.1:8080
    PUBLIC_URL=http://127.0.0.1
    HUMIO_SOCKET_BIND=0.0.0.0
    HUMIO_HTTP_BIND=0.0.0.0
    ```
7. Create the Humio service file:
    ```
    # nano /etc/systemd/system/humio.service
    ```
8. Add the following content to the service file:
    ```
    [Unit]
    Description=Humio service
    After=network.service
    
    [Service]
    Type=notify
    Restart=on-abnormal
    User=humio
    Group=humio
    LimitNOFILE=250000:250000
    EnvironmentFile=/etc/humio/server.conf
    WorkingDirectory=/var/humio
    ExecStart=/usr/bin/java -server -XX:+UseParallelOldGC -Xms4G -Xmx32G -XX:MaxDirectMemorySize=64G -Xss2M -Xlog:gc*,gc+jni=debug:file=/var/log/humio/gc_humio.log:time,tags:filecount=5,filesize=102400 -Dhumio.auditlog.dir=/var/log/humio -Dhumio.debuglog.dir=/var/log/humio -jar /opt/humio/server.jar
    
    [Install]
    WantedBy=default.target
    ```
9. Change ownership of the humio files
    ```
    # chown -R humio:humio /opt/humio /etc/humio/filebeat /var/log/humio /var/humio/data
    ```
10. Start the Humio service
    ```
    # systemctl start humio
    ```
11. Verify that Humio is up and running through a web browser: http://server_IP_or_hostname:8080

{{< figure src="/pages/installation/Humio-Initial-Screen.png" >}}



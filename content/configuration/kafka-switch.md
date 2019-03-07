---
title: "Switching Kafka"
---

Humio uses Kafka for queuing incoming messages and for
storing shared state when running Humio in a cluster setup.  

It is possible for Humio to snapshot its state. and continue running using a new Kafka cluster. 
This can be usefull in situations where you want to change infrastructure or if there is problems with the current Kafka/Zookeeper cluster.  
One  example could be all Zookeeper machines have written the disk full 
and afterwards Zookeeper will not start because of file inconsistencies. 

This section describes the procedure for doing a Kafka switch 


## Kafka Switch


### Stop sending data to Humio
If it is possible, stop sending data to Humio. 
Then wait for Humio to process all data on the ingest queue.
The 'Humio stats' dashboard in the Humio repository has the graphs 'Events processed after ingest queue by host per second' and 'Ingest latency' that will show this.   
If there is data on the ingest queue after closing Humio it will be lost as the queue is reset or another queue will be used.  


### Close Humio Kafka and Zookeeper 

* Stop all Humio processes on all machines.
* Stop all Kafka processes on all machines.
* Stop all Zookeeper processes on all machines.

### Switch Kafka and Zookeeper
There are 3 options for switching Kafka and Zookeeper.
Setup a new Kafka/Zookeeper cluster and configure Humio to use that.   
You can reset the current Kafka and Zookeeper cluster by deleting thier data directories on the filesystem on each node. 
This is the same as starting up a new and empty Kafka/Zookeeper cluster.
Another options is to spin up new Zookeeper/Kafka clusters. Or let Humio use new queues/topics on the existing Kafka cluster.
When reusing the same Kafka cluster, Humio must be configured with a new `HUMIO_KAFKA_TOPIC_PREFIX` to detect the changes.  
The options are described below:

##### Use a new Kafka/Zookeeper cluster
This is straightforward. Just configure Humio to use the new Kafka cluster.

##### Delete Kafka and Zookeeper data and reuse the existing cluster
First Delete everything inside Kafka's data directory.
Then delete the folder `version-2` inside Zookeepers data directory. 
It is important to not delete the Zookeeper file `myid` in Zookeepers data directory.
`myid` is a configuration file that contains the id of the Zookeeper node in the Zookeeper cluster and must be there at startup.
Now we have actually created completely new Zookeeper and Kafka clusters.

##### Create new Kafka queues/topics with new names on the existing Kafka cluster
Instead of resetting Kafka Zookeeper as described above it is possible to let Humio use a new set of queues in the existing Kafka cluster.
For this to work, Humio must be configured with a new `HUMIO_KAFKA_TOPIC_PREFIX`. 
It is important to note that it will not work to delete and recreate topics with the same names.
In that case Humio cannot detect the Kafka switch.  
If Kafka is managed by Humio (`KAFKA_MANAGED_BY_HUMIO`), the new topics will be created automatically when Humio starts up. 
Otherwise topics must be created externally before Humio is started.   


### Start Kafka and Zookeeper
Now we are ready to get the Kafka/Zookeper cluster started.
This is typically done by starting the Zookeeper nodes. Wait for all nodes to be running and verify the Zookeeper cluster. 
Then start all kafka nodes, wait for them to be running and verifying the Kafka cluster. 

### Start Humio
Now it is time to start the Humio nodes.

It is important to start one Humio node first. This node will detect the kafka switch and create a new epoc in Humio.  
If you are running multiple Humio processes on one Machine (with multiple CPUs), make sure to only start one Humio process.  
Too verify the Kafka switch was detected and handled - look for this logline:
```
Switching epoch to=${epochKey} from=${latestEpoch.kafkaClusterId} - I'm the first cluster member to get here for this kafka. newEpoch=${newEpoch}
```

When the first node is up and running and the above logline confirms a new epoch has been created. The rest of the Humio nodes can be started.

Now the Humio cluster should be running again. Check the cluster nodes in the admin UI: http://$HUMIOHOST/system/administration/partitions/ingest


### Summary

In short, to do a Kafka switch follow these steps:  

* Stop all Humio processes on all nodes
* Stop all Kafka processes on all nodes
* Stop all Zookeeper processes on all nodes
* Delete Zookeeper and Kafka data (or use new Kafka queues)
* Start all Zookeeper processes on all nodes.
* Verify the Zookeeper cluster
* Start all Kafka processes on all nodes
* Verify the Kafka cluster
* Start one Humio node and let it change epoc
* Verify the epoch has changed
* start the other Humio processes on all nodes. 
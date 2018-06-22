---
title: "Cluster Management API"
weight: 500
---

This page provides information about the HTTP API for managing
on-premises installations of Humio.

All requests require **root-level access**. See [API token for local root access]({{< relref "root-access.md#root-token" >}}).

Note, this API is still very much _work-in-progress_.


## Available Endpoints

| Endpoint                                                                           | Method                                                                  | Description                                          |
| ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ---------------------------------------------------- |
| `/api/v1/clusterconfig/members`                                                    | [GET](#list-cluster-members)                                            | List cluster members                                 |
| `/api/v1/clusterconfig/members/$HOST`                                              | [GET](#modifying-a-host-in-your-cluster)                                | Get a host in your cluster                           |
| `/api/v1/clusterconfig/members/$HOST`                                              | [PUT](#modifying-a-host-in-your-cluster)                                | Modifying a host in your cluster                     |
| `/api/v1/clusterconfig/members/$HOST`                                              | [DELETE](#deleting-a-host-from-your-cluster)                            | Deleting a host from your cluster                    |
| `/api/v1/clusterconfig/segments/partitions/setdefaults`                            | [POST](#applying-default-partition-settings)                            | Applying default partition settings                  |
| `/api/v1/clusterconfig/segments/partitions`                                        | [GET, POST](#querying-and-assigning-storage-partitions-to-hosts)        | Querying and assigning storage partitions to hosts   |
| `/api/v1/clusterconfig/segments/partitions/set-replication-defaults`               | [POST](#assigning-default-storage-partitions-to-hosts)                  | Assigning default storage partitions to hosts        |
| `/api/v1/clusterconfig/segments/distribute-evenly`                                 | [POST](#moving-existing-segments-between-hosts)                         | Moving existing segments between hosts               |
| `/api/v1/clusterconfig/segments/prune-replicas`                                    | [POST](#pruning-replicas-when-reducing-replica-setting)                 | Pruning replicas when reducing replica setting       |
| `/api/v1/clusterconfig/segments/distribute-evenly-reshuffle-all`                   | [POST](#moving-existing-segments-between-hosts)                         | Moving existing segments between hosts               |
| `/api/v1/clusterconfig/segments/distribute-evenly-to-host/$HOST`                   | [POST](#moving-existing-segments-between-hosts)                         | Moving existing segments between hosts               |
| `/api/v1/clusterconfig/segments/distribute-evenly-from-host/$HOST`                 | [POST](#moving-existing-segments-between-hosts)                         | Moving existing segments between hosts               |
| `/api/v1/clusterconfig/ingestpartitions`                                           | [GET, POST](#ingest-partitions)                                         | Get/Set ingest partitions                            |
| `/api/v1/clusterconfig/ingestpartitions/setdefaults`                               | [POST](#ingest-partitions)                                              | Set ingest partitions defaults                       |
| `/api/v1/clusterconfig/ingestpartitions/distribute-evenly-from-host/$HOST`         | [POST](#ingest-partitions)                                              | Move ingest partitions from host                     |
| `/api/v1/clusterconfig/kafka-queues/partition-assignment`                          | [GET, POST](#managing-kafka-queue-settings)                             | Managing kafka queue settings                        |
| `/api/v1/clusterconfig/kafka-queues/partition-assignment/set-replication-defaults` | [POST](#managing-kafka-queue-settings)                                  | Managing kafka queue settings                        |
| `/api/v1/listeners`                                                                | [GET,POST](#adding-a-ingest-listener-endpoint)                          | Add tcp listener (used for Syslog)                   |
| `/api/v1/listeners/$ID`                                                            | [GET,DELETE](#adding-a-ingest-listener-endpoint)                        | Add tcp listener (used for Syslog)                   |
| `/api/v1/dataspace/$REPOSITORY_NAME/taggrouping`                                   | [GET,POST](#setup-grouping-of-tags)                                     | Setup grouping of tags                               |
| `/api/v1/dataspaces/$REPOSITORY_NAME/datasources/$DATASOURCEID/autosharding`       | [GET,POST,DELETE](#configure-auto-sharding-for-high-volume-datasources) | Configure auto-sharding for high-volume datasources. |
| `/api/v1/status`       | [GET](#status-endpoint) | Get status and version of node |


## Manage your cluster

All cluster operation on the Humio cluster presumes a running Kafka/Zookeeper cluster.
All Humio instances in a cluster must be hooked up to the same Kafka cluster,
preferably being able to talk to more than one Kafka and zookeeper server instance.

The humio cluster is conceptually a set of 'Hosts' and 'partitions'.
There are partitions for "ingest" and for "storage".
Each host is assigned a (possibly empty) set of partitions of these two kinds.
You manage the load on each server by assigning partitions to hosts.

When data arrives at humio ("being ingested") it is routed to the host that handles the "ingest partition" selected for that data.
That host then collects data from that input stream into a segment. Once the segment is full, the host selects a set of hosts, through the storage partitions, to hold the completed segment.

Humio hosts may be added to, or removed from, a running cluster.


## Add a host to your cluster

Assuming you have a cluster of one or more humio nodes, add a with these steps:

1.  Add a new server as described in the installation documentation, and configure it to talk to the existing kafka-cluster

1.  Start humio on the new server with an empty "/data/humio-data" directory. Humio needs a way to get hold of the shared state in the cluster, from one of these sources:

    1.  If humio does not have BACKUP configured, you can copy the file `global-data-snapshot.json` from another member of the cluster, and place that in the /data/humio-data" directory. Make sure not to copy any other files.
    1.  If humio has BACKUP configured, the shared backup folder including long-term copies is also searched for a copy of the current shared state.
    1.  Humio also fetches a snapshot from the Kafka-queue named "global-snapshots".
    1.  Humio selects the latest, in terms of epoch and offset, recorded inside these snapshots.

1.  The new Humio instance will pull the latest events in the shared state from Kafka queue "global-events", and detect that it is a fresh member of an existing cluster.

1.  The new Humio instance register itself in the cluster, but does not have any partitions assigned.
    If "BOOTSTRAP_HOST_ID" is set in the configuration, this sets the desired ID.
    If it is not set, it is auto-selected by the server.

1.  The other hosts in the cluster need to know where to find the new server.

    1.  Use "EXTERNAL_URL" in the configuration to set this before the initial start of the instance.
    1.  You can you the api to modify this using GET/PUT.

1.  To get the host to do some work, assign partitions to it using the API below.

## List cluster members

```
GET    /api/v1/clusterconfig/members
```

Example:

```shell
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/members"
```

## Modifying a host in your cluster

You can fetch / re-post the object representing the host in the cluster using GET/PUT requests.
$HOST is the integer-id of the new host.

```
GET    /api/v1/clusterconfig/members/$HOST
PUT    /api/v1/clusterconfig/members/$HOST
```

Example:

```shell
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/members/1" > host-1.json
curl -XPUT -d @host-1.json -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/members/1"
```

outputs:

```json
{"vhost":1,"uuid":"7q2LwHv6q3C5jmdGj3EYL1n56olAYcQy","internalHostUri":"http://localhost:8080","displayName":"host-1"}
```

You can edit the fields internalHostUri and displayName in this structure and POST the resulting changes back to the server, preserving the vhost and uuid fields.

## Deleting a host from your cluster

If the host does not have any segments files, and no assigned partitions, there is no data loss when deleting a host.

```
DELETE    /api/v1/clusterconfig/members/$HOST
```

Example:

```shell
curl -XDELETE -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/members/1"
```

It is possible to drop a host, even if it has data and assigned partitions, by adding the query parameter "accept-data-loss" with the value "true".

{{% notice warning %}}
This silently drops your data.
{{% /notice %}}

Example:

```shell
curl -XDELETE -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/members/1?accept-data-loss=true"
```

## Applying default partition settings

This is a shortcut to getting all members of a cluster to have the same share of the load on both ingest and storage partitions.

```
POST   /api/v1/clusterconfig/partitions/setdefaults
```

Example:

```shell
curl -XPOST -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/partitions/setdefaults"
```

## Querying and assigning storage partitions to hosts

When a data segments is complete, the server select the host(s) to place the segment on by looking up a segment-related key in the storage partition table.
The partitions map to a set of hosts. All of these hosts are then assigned as owners of the segment, and will start getting their copy shortly after.

You can modify the storage partitions at any time.
Any number of partitions larger than the number of hosts is allowed, but the recommended the number of storage partitions is 24 or similar fairly low number.
There is no gain in having a large number of partitions.

Existing segments are not moved when re-assigning partitions. Partitions only affect segments completed after they are POST'ed.

```
GET    /api/v1/clusterconfig/segments/partitions
POST   /api/v1/clusterconfig/segments/partitions
```

Example:

```shell
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/segments/partitions" > segments-partitions.json
curl -XPOST -d @segments-partitions.json -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/segments/partitions"
```

## Assigning default storage partitions to hosts

When the set of hosts has been modified, you likely want to make the storage partitions distribute the storage load evenly among the current set of hosts.
The following API allows doing that, while also selecting the number of replicas to use.

Any number of partitions larger than the number of hosts is allowed, but the recommended the number of storage partitions is 24 or similar fairly low number.
There is no gain in having a large number of partitions.

The number of replicas must be at least one, and at most the number of hosts in the cluster. The replicas selects how many hosts should keep a copy of each completed segment.

```
POST   /api/v1/clusterconfig/segments/partitions/set-replication-defaults
```

Example:

```shell
echo '{ "partitionCount": 7, "replicas": 2 }' > settings.json
curl -XPOST -d @settings.json -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/segments/partitions/set-replication-defaults"
```

## Pruning replicas when reducing replica setting

If the number of replicas has been reduced, existing segments in the cluster do not get their replica count reduced. In order to reduce the number of replicas on existing segments, invoke this:

```
POST   /api/v1/clusterconfig/segments/prune-replicas
```

```shell
curl -XPOST -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/segments/prune-replicas"
```

## Moving existing segments between hosts

There is API for taking the actions moving the eixsting segments between hosts.

1.  Moving segments so that all hosts have their "fair share" of the segments, as stated in storage partitioning setting, but as mush as possible leaving segments where they are.
    It's also possible to apply the current partitioning scheme to all existing segments, possibly moving every segment to a new host.

1.  It's possible to move all existing segments off a host.
    If that host is not assigned any partitions at all (both storage and ingest kinds), this then releaves the host of all duties, preparing it to be deleted from the cluster.

1.  If a new host is added, and you want it to take its fair share of the current stored data, use the "distribute-evenly-to-host" variant.

```
POST   /api/v1/clusterconfig/segments/distribute-evenly
POST   /api/v1/clusterconfig/segments/distribute-evenly-reshuffle-all
POST   /api/v1/clusterconfig/segments/distribute-evenly-to-host/$HOST
POST   /api/v1/clusterconfig/segments/distribute-evenly-from-host/$HOST
Optional; Add a "percentage=[0..100]" query parameter to only apply the action to a fraction of the full set.
```

Examples:

```shell
curl -XPOST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/segments/distribute-evenly"
curl -XPOST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/segments/distribute-evenly-reshuffle-all?percentage=3"
curl -XPOST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/segments/distribute-evenly-to-host/1"
curl -XPOST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/segments/distribute-evenly-from-host/7"
```

## Ingest Partitions

These route the incoming data while it is "in progress".

Warning: Do not `POST` to this API unless the cluster is running fine,
with all members connected and active. All ingest traffic stops for a few seconds when being applied.

Ingest traffic does not start before all hosts are ready, thus if a host is failing, ingest does not resume.

1.  GET/POST the setting to hand-edit where each partition goes. You cannot reduce the number of partitions.

1.  Invoke "setdefaults" to distribute the current number of partitions evenly among the known hosts in the cluster

1.  Invoke "distribute-evenly-from-host" to reassign partitions currently assigned to $HOST to the other hosts in the cluster.

```
GET    /api/v1/clusterconfig/ingestpartitions
POST   /api/v1/clusterconfig/ingestpartitions
POST   /api/v1/clusterconfig/ingestpartitions/setdefaults
POST   /api/v1/clusterconfig/ingestpartitions/distribute-evenly-from-host/$HOST
```

Example:

```shell
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/ingestpartitions" > ingest-partitions.json
curl -XPOST -d @ingest-partitions.json -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/ingestpartitions"
```

## Managing kafka queue settings

The ingest queues are partitions of the Kafka queue named "humio-ingest".
Humio offers an API for editing the Kafka partition to broker assignments this queue.
Note that changes to these settings are applied asynchronously, thus you can get the previous settings, or a mix with the latest settings, for a few seconds after applying a new set.

```
GET    /api/v1/clusterconfig/kafka-queues/partition-assignment
POST   /api/v1/clusterconfig/kafka-queues/partition-assignment
POST   /api/v1/clusterconfig/kafka-queues/partition-assignment/set-replication-defaults
```

Example:

```shell
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/kafka-queues/partition-assignment" > kafka-ingest-partitions.json
curl -XPOST -d @kafka-ingest-partitions.json -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/kafka-queues/partition-assignment"

echo '{ "partitionCount": 24, "replicas": 2 }' > kafka-ingest-settings.json
curl -XPOST -d @kafka-ingest-settings.json -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/kafka-queues/partition-assignment/set-replication-defaults"
```

## Adding a ingest listener endpoint

You can ingest events using one of the many [existing integration](/sending-data/integrations/) but when your requirements do
not match, perhaps you can supply a stream of events on TCP, separated by line feeds.
This API allows you to create and configure a TCP listener for such events.
Use cases include accepting "rsyslogd forward format" and similar plain-text event streams.

```
GET    /api/v1/listeners
POST   /api/v1/listeners
GET    /api/v1/listeners/$ID
DELETE /api/v1/listeners/$ID
```

If you use [rsyslog for transport of logs](http://www.rsyslog.com/doc/v8-stable/configuration/templates.html#standard-template-for-forwarding-to-a-remote-host-rfc3164-mode)
then this example serves as a starting point:

```
# Example input line on the wire:
<14>2017-08-07T10:57:04.270540-05:00 mgrpc kernel: [   17.920992] Bluetooth: Core ver 2.22
```

Creating a parser accepting rsyslogd forward format: [(How to add a parser)](#create-or-update-parser)

```shell
cat << EOF > create-rsyslogd-rfc3339-parser.json
{ "parser": "^<(?<pri>\\\\d+)>(?<datetimestring>\\\\S+) (?<host>\\\\S*) (?<syslogtag>\\\\S*): ?(?<message>.*)",
  "kind": "regex",
  "parseKeyValues": true,
  "dateTimeFormat": "yyyy-MM-dd'T'HH:mm:ss[.SSSSSS]XXX",
  "dateTimeFields": [ "datetimestring" ]
}
EOF
curl -XPOST \
 -d @create-rsyslogd-rfc3339-parser.json \
 -H "Authorization: Bearer $TOKEN" \
 -H 'Content-Type: application/json' \
 "http://localhost:8080/api/v1/dataspaces/$REPOSITORY_NAME/parsers/rsyslogd-rfc3339"
```

Example setting up a listener using the rsyslogd forward format added above:

```shell
cat << EOF > create-rsyslogd-listener.json
{ "listenerPort": 7777,
  "kind": "tcp",
  "dataspaceID": "$REPOSITORY_NAME",
  "parser": "rsyslogd-rfc3339",
  "bindInterface": "0.0.0.0",
  "name": "my rsyslog input",
  "vhost": 1
}
# "bindInterface" is optional. If set, sets local interface to bind on to select network interface.
# "vhost" is optional. If set, only the cluster host with that index binds the port.

EOF
curl -XPOST \
  -d @create-rsyslogd-listener.json \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  'http://localhost:8080/api/v1/listeners'

curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/listeners"
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/listeners/tcp7777"
```

Listeners also support UDP by setting `kind` to `"udp"`. For UDP, each UDP datagram is
ingested as a single log line (i.e. it is not split by newlines).

It is possible to specify that fields in the incomming events, should be turned into tags.
This can be done by setting `"tagFields": ["fielda", "fieldb"]` when creating a listener. Only use tags like this if you really need it.

To reduce packet loss in bursts of UDP traffic, please increase the maximum allowed receive buffer size for UDP.
Humio will try to increase the buffer to up to 128MB, but will accept whatever the system sets as maximum.

```shell
# To set to 16MB.
sudo sysctl net.core.rmem_max=16777216
```

## Setup grouping of tags

```
GET    /api/v1/dataspaces/$REPOSITORY_NAME/taggrouping
POST   /api/v1/dataspaces/$REPOSITORY_NAME/taggrouping
```

Please note that this is a feature for advanced users only.

Humio recommends most users to only use the parser as a tag, in the field `#type`.
This is usually sufficient.

Using more tags may speed up queries on large data volumes, but only works on a bounded value-set for the tag fields.
The speed-up only affects queries prefixed with `#tag=value` pairs that significantly filter out input events.

Tags are the fields with a prefix of `#` that are used internally to do sharding of data into smaller streams
A `datasource` is is created for every unique combination of tag values set by the clients (e.g. data-shippers)
Humio will reject ingested events once a certain number of datasources get created.
The limit is currently 10.000 pr. repository.

For some use cases, such as having the "client IP" from an access log as a tag,
too many different tags will arise.
For such a case, it is necessary to either stop having the field as a tag, or
create a grouping rule on the tag field.
Existing data is not re-written when grouping rules are added or changed.
Changing the grouping rules will thus in it-self create more datasources.

Example: Setting the grouping rules for repository `$REPOSITORY_NAME`
to hash the field `#host` into 8 buckets, and `#client_ip` into 10 buckets.
Note how the field names do not include the `#` prefix in the rules.

```shell
curl http://localhost:8080/api/v1/dataspaces/$REPOSITORY_NAME/taggrouping \
  -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '[ {"field":"host","modulus": 8}, {"field":"client_ip","modulus": 10} ]'
```

Adding a new set of rules using POST replaces the current set.
The previous sets are kept, and if a previous one matches, then the previous one is reused.
The previous rules are kept in the system, but may be deleted by Humio once all datasources referring them has been deleted (through retention settings)

When using grouped tags in the query field, you can expect to get a speed-up of approximately the modulus compared to not including the tags in the query,
provided you use an exact match on the field. If you use a wildcard (`*`) in the value for the grouped tag, the implementation currently scans all
datasources that have a non-empty value for that field and filter the events to only get the results the match the wildcard pattern.

For non-grouped tag fields, using a wildcard at either end of the value string to match is efficient.

Humio also support auto-grouping of tags using the configuration variables
`MAX_DISTINCT_TAG_VALUES` (default is `1000`) and `TAG_HASHING_BUCKETS` (default is `16`).
When an event arrive with a tag field with a new value, the number of distinct
values for the tag is checked against `MAX_DISTINCT_TAG_VALUES`.
It this threshold is exceeded, a new grouping rule is added with the modulus set
to the value set in `TAG_HASHING_BUCKETS`.

IF you happen to read this and is using a hosted Humio instance, please contact support
if you wish to add grouping rules to your repository.

## Importing a repositories from another Humio instance (BETA)

You can import ingest tokens, user, dashboards and segments files from another Humio instance.
You need to get a copy of the `/data/humio-data/global-data-snapshot.json` from the origin server.

You also need to copy the segments files that you want to
import. These must be placed in the folder
`/data/humio-data/ready*for_import_dataspaces` using the following
structure:

`/data/humio-data/ready_for_import_dataspaces/dataspace*$NAME`

You should copy the files for the repository to the server into another
folder while the copying is happening, and then move it to the proper
name once it's ready.

The folder `/data/humio-data/ready_for_import_dataspaces` must be
read+writeable for the humio-user running the server, as it moves the
files to another directory and deletes the imported files when it is
done with them, one at a time.

Example:

```shell
NAME="my-repository-name"
sudo mkdir /data/humio-data/ready_for_import_dataspaces
sudo mv /data/dataspaces-from-elsewhere/dataspace_$NAME /data/humio-data/ready_for_import_dataspaces
sudo chown -R humio /data/humio-data/ready_for_import_dataspaces/
curl -XPOST -d @from-elsewhere-global-data-snapshot.json  -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/importdataspaces/$NAME"
```

The `POST` imports the metadata, such as users and dashboards, and moves
the repository folder from
`/data/humio-data/ready_for_import_dataspaces` to
`/data/humio-data/import`. A low-priority background task will then
import the actual segments files from that point on.

You can start using the ingest tokens and other data, that are not
actual log-events as soon as the POST has completed.

You can run the `POST` starting the import of the same repository more
than once. This is useful if you wish to import only a fraction of the
data files at first, but get all the metadata. When you rerun the POST,
the metadata is inserted/updated again, if it no longer matches
only. The new repository files will get copied at that point in time.

## Configure auto-sharding for high-volume datasources

A datasource is ultimately bounded by the volume that one CPU thread can manage
to compress and write to the filesystem. This is typically in the 1-4 TB/day range.
To handle more ingest traffic from a specific data source, you ned to provide more
variability in the set of tags. But in some cases it may not be possible or desirable to adjust
the set of tags or tagged fields in the client. To solve this case, Humio supports
adding a synthetic tag, that is assigned a random number for each (small bulk) of events.

The API allows `GET`/`POST`/`DELETE` of the settings. `POST` with no arguments
applies a default number of shards, currently _4_.

The API requires root access.

## Status endpoint

The status endpoint can be used to check whether the node can be reached and which version it's running.
Useful as e.g. a smoke test after a humio upgrade or as a health check to be used with service discovery tools such as Consul.

Example:

```shell
$ curl -s https://cloud.humio.com/api/v1/status
{"status":"ok","version":"1.1.0--build-2965--sha-581e6ec64"
```

### Examples

```shell
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/dataspaces/$REPOSITORY_NAME/datasources/$DATASOURCEID/autosharding"
curl -XPOST -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/dataspaces/$REPOSITORY_NAME/datasources/$DATASOURCEID/autosharding"
curl -XPOST -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/dataspaces/$REPOSITORY_NAME/datasources/$DATASOURCEID/autosharding?number=7"
curl -XDELETE -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/dataspaces/$REPOSITORY_NAME/datasources/$DATASOURCEID/autosharding"
```

Humio also supports detecting if there is high load on a datasource, and automatically trigger this auto-sharding on the datasources.
This is configured through the settings `AUTOSHARDING_TRIGGER_DELAY_MS`, which is compared to the time an even spends in the ingest pipeline inside Humio.

When the delay threshold is exceeded, the number of shards on that datasource (combination of tags) is doubled.
The default value for `AUTOSHARDING_TRIGGER_DELAY_MS` is 60000 ms (60 seconds).

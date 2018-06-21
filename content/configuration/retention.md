---
title: "Retention"
---

You can make Humio delete the data after a while to keep your disks from overflowing.
This is in the web interface. Retention can be set for both size (compressed and uncompressed) and age of data.

Retention deletes events in large chunks ("segments"), not deleting individual events.

The three types of retention are independent - data gets deleted when any one of them marks it for deleting.

## By Compressed Size {#compressed}

The "compressed" setting is designed to allow the administrator to prevent the file system from overflowing.
Configure the "compressed" settings for each repository so that the sum of all compressed sizes is less than the space available on the disk.

The compressed size calculation deletes data based on the amount of disk space consumed taking replicas into account
until the amount on disk is below the setting. Replicas are handled by counting copies in excess of the segment-replication settings as "extra".

An example: In a cluster of 3 humio-instances, a segment-replication of 3, and a CompressedSize of 50 GB,
the total disk usage on those three machines for this repository would be 150 GB. This lets the users see 50 GB of compressed data.

If the segment replication setting is then changed to 2, the allowed disk usage drops to 100 GB in total on the three machines.
The retention-job will then delete the oldest segments, leaving approximately 33 GB of searchable data at first.
When more data flows in through ingest, the user will get back to having 50 GB of searchable compressed data in the 100 GB on disk,
likely dstributed evenly as 33GB on each Humio instance in the cluster.

## By Uncompressed Size {#uncompressed}

The "uncompressed" setting is designed to delete data based on a promise to keep at least this much of the "input".
Original size is measured as the size stored before compression and is thus the size of the internal format,
not the data that was ingested. It also includes the size of any additional fields sent along with the raw events.

The uncompressed size retention triggers a delete when it is able to retain at least the amount specified as uncompressed limit.
Uncompressed retention does not consider multiple replicas as more than on copy, as it is based on the amount of data that the users see.

## By Age {#age}

Data gets deleted when the latest event in the chunk is older than the configured retention.
In order to make sure that a user cannot see events older than the configured limit, Humio also restricts the time interval when searching to
the interval allowed by this retention setting. Retention by age effectively hides any event that is too old, even if the chunk still has other events that are still visible. The disk space is reclaimed once the latest event is sufficiently old.

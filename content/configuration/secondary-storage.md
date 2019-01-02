---
title: "Secondary storage"
---

This is also known as Hot/Cold storage.

Secondary storage is intended for usages where the primary is
"low-latency and small", such as NVME, and the secondary is
"high-latency but very large", such as a SAN spanning many spinning
disks.

Only segment files get copied to the secondary storage.

## Files get moved based on disk space available

When enabled Humio will copy segment files to secondary storage once
the primary disk reaches the usage threshold set using
`PRIMARY_STORAGE_PERCENTAGE`.  Humio does not check what is using the
space, it bases the decision on what the OS responds for "disk space
used" and "disk space total" for the mount point that the primary data
dir is on.

When the threshold is exceeded Humio will copy files totaling the
excess number of bytes to the secondary storage, validate that the
internal CRC in the resulting copies check out, and then delete the
segment file from the primary data dir. The files are selected based
on the latest event timestamp in them, to keep most recent events on
the primary disk. This is done to get the best possible query
performance from the assumed faster primary drive, since Humio is
normally used for querying the latest data.

The extra storage gained is thus almost the available space on of the
secondary data dir, as only a single segment file can be on both
volumes at once.

Note that the secondary dir needs to be private to the Humio node,
just like the primary dir does. Never share data directories across Humio
nodes!

### Example

A server with 1TB NVME being used for system files, Kafka data and
Humio data. Adding a 2TB SAN connection (or 2x2TB local spinning disks
in a mirror) and then designating that as secondary storage directory
allows Humio to store up to 2.8TB, while still querying the latest
~800GB from the NVME, and also keeping and segment files still being
constructed on the NVME.  When searching beyond what the NVME holds,
Humio will read from the slower disks.

## Configuring

Humio needs to be told where to store the secondary copies i.e. the location of the fileystem on the slower drive.

{{% notice note %}}
When using docker, make sure to mount the secondary directory
into the container as well.
{{% /notice %}}


```
# SECONDARY_DATA_DIRECTORY enables the feature
# and sets where to store the files.
SECONDARY_DATA_DIRECTORY=/secondaryMountPoint/humio-data2

# PRIMARY_STORAGE_PERCENTAGE options decides the amount of data (Humio
# and otherwise) that the drive holding the data dir must at least hold
# before Humio decides to move any segments files to the secondary location.
# If set to zero, Humio will move files to secondary as soon as possible,
# which is when they turn immutable. (completed segment files)
# (Default 80)
PRIMARY_STORAGE_PERCENTAGE=80
```



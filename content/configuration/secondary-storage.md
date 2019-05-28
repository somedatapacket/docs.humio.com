---
title: "Secondary storage"
---

This is also known as Hot/Cold storage.

Secondary storage is intended for usages where the primary is
"low-latency and fast", such as NVME, and the secondary is
"high-latency but very large", such as a SAN spanning many spinning
disks.

Only segment files get moved to the secondary storage. Older files get
moved before younger ones.

## Files get moved based on disk space available

When enabled Humio will move segment files to secondary storage once
the primary disk reaches the usage threshold set using
`PRIMARY_STORAGE_PERCENTAGE`.  Humio does not check what is using the
space, it bases the decision on what the OS responds for "disk space
used" and "disk space total" for the mount point that the primary data
dir is on.

When the threshold is exceeded Humio will copy files totaling the
excess number of bytes to the secondary storage, and then delete the
segment files from the primary data dir. The files are selected based
on the latest event timestamp in them, to keep most recent events on
the primary disk. This is done to get the best possible query
performance from the assumed faster primary drive, since Humio is
normally used for querying the latest data.

The extra storage gained is thus almost the available space on of the
secondary data dir, as only a single segment file is ever present on
both volumes at once.

Note that the secondary dir needs to be private to the Humio node,
just like the primary dir does. Never share data directories across Humio
nodes!

### Example

A server with 1TB NVME being used for system files, Kafka data and
Humio data. Adding a 2TB SAN connection (or 2x2TB local spinning disks
in a mirror) and then designating that as secondary storage directory
allows Humio to store up to 2.8TB, while still querying the latest
~800GB from the NVME, and also keeping all segment files still being
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
# which is when they become immutable completed segment files.
# (Default 80)
PRIMARY_STORAGE_PERCENTAGE=80
```


### Adding a new primary and making the current primary disk be secondary

Say you have a slow disk as your only (and thus primary) disk right
now for Humio.  You add a new faster disk to the server, and want to
use that disk as the primary, while leaving the bulk of the data on
the old slow disk.

While this is possible, there is a bit of work involved, as only
completed segment files can reside n the secondary storage. All other
support files, and segment files in progress need to reside on the
primary disk. Humio must be shut down while this operation takes place.

Basically only files matching `humiodata.*` (and `bloom5*`) can stay
on the secondary storage, everything else must be on the primary. The
tricky bit is moving the soft-links `humiodata.current` along with the
file they point to.

You will need to move some specific files from the "new secondary"
onto the "new primary while the system is shut down for that to work,
as some files must be on the primary. Here are their names, as they
are below `/humio-data`. The directory structure must be preserved.

• files matching `dataspace_*/datasource_*/humiodata.current`
• For all the above `humiodata.current` soft-links, the file it points to as well.
• `uploadedfiles` directory
• `cluster_membership.uuid` file
• `global-data-snapshot.json` file


If the above files are moved from the secondary to the primary, it
should work fine to leave the remaining segment files, and start out
with almost all data being on secondary. Or, if you want, move
selected parts of the completed segment files from secondary to
primary as well, to get the improved performance from the new disk on
searches that hit those. One could move e.g. all segments that are
less than 7 days old if that matches the search typical search range
for the system.

Humio will not move files from secondary back to primary. Once the
primary is full later on, Humio will start migrating segment file from
primary to secondary.
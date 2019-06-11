---
title: "Instance Sizing"
weight: 1
aliases: ["appendix/instance_sizing"]
---

This page describes how to choose hardware and size a Humio installation.

Sizing depends on your usage patterns, so we recommend first doing an example setup to see how Humio works
with your data.  The following provides some examples.

For clustered setups, and/or setups with data replication, we currently recommend contacting
humio support for specific suggestions.

## Background

With Humio, the limiting factor is usually query speed, not ingest capacity.  Query speed depends:
Number of CPUs, available RAM and disk speed.  The following numbers are all "ballpark recommendations", your exact circumstances
may be different.

A running Humio instance will use something like 10-20% of available RAM - the rest of available memory is used for OS-level
file system cache. If you're for example on an AWS `m4.4xlarge` (60GB RAM, 16 vCPUs), then you would typically see
~10GB used for running Humio, and ~50GB available for file system caches.    The 50GB cache represents compressed Humio
data files which are optimized for querying; this way you will typically observe recently read or written data
is faster to query.

Data is typically compressed 5-10x, depending on what it is.  Your mileage may wary, but short log lines
(http access logs, syslog, etc.) compress better than longish JSON logs (such as those coming from [Metricbeat]({{< ref "metricbeat.md" >}})).

For data available as compressed data in the OS-level cache, Humio generally provides query speed at 1GB/s/vCPU,
or 1GB/s/hyperthread.  So, on a `m4.4xlarge` instance with 16 vCPUs, you observe ~16GB/s queries.  If your compression
ratio is 6x, then that means that the last 50GB x 6 = 300GB of ingested data can be read at this speed.

We recommend that you should be able to keep 48hrs of data accessible for fast querying for a good experience, so
thus we recommend that a `m4.4xlarge` is used for up to 150GB/day ingest; and this will let you do a full scan of
a day's worth of data in less than 10 seconds.  Many queries will be faster because you usually narrow the search
by specifying tags or other time limitations.

On this setup, a 300GB/day ingest will use ~5% of your CPU load, so there is plenty of headroom for data spikes
and running dashboards.

Searches going beyond what fits in the OS-level file system caches can
be significantly slower, as they depend on the disk I/O performance.
If you have sufficiently fast NVME-drives or similar that can deliver
the compressed data as fast as the CPU cores can decompress them, then
there is virtually no penalty for doing searches that extend beyond
the size of the page cache.  We built Humio to run on local SSDs, so
it is not (presently) optimized to run on high-latency EBS storage or
slow spinning disks. But it will work, especially if most searches are
"live" or within the page cache. Humio reads files using "read ahead"
instructions to the Linux kernel, which allows for file systems on
spinning disks to read continuous ranges of blocks rather than random
blocks.

## Rules of thumb

- One vCPU/hyperthread can ingest 250GB/day.
- Search speed is 1 GB per vCPU/hyperthread (for data in RAM or on fast disks).
- Note that a vCPU can do only one of the above at any point in time - Search speed is thus influenced by time spent on ingest. 
- Compression ratio * RAM is how much data can be kept in memory (Using OS-level file system cache).
- Fast SSDs can achieve as good search speeds as when data is in RAM.
- For better performance, the disk subsystem should be able to read data at at least 150MB/s/core when not cached.


### Example
- Assume data compresses 9x (test your setup and see, better compression means better performance).
- You need to be able to hold 48hrs of compressed data in 80% of you RAM. (But only if your disks cannot keep up)
- You want enough hyper threads/vCPUs (each giving you 1GB/s search) to be able
  to search 24hrs of data in less than 10 seconds.
- You need disk space to hold your compressed data. Never fill your disk more than 80%.

> Your machine has 64G of ram, and 8 hyper threads (4 cores), 1TB of storage.
  Your machine can hold 460GB of ingest data compressed in ram, and process 8GB/s.  In this case
  that means that 10 seconds worth of query time will run through 80GB of data.  So this machine
  fits an 80GB/day ingest, with +5 days data available for fast querying.  
  You can store 7.2TB of data before your disk is 80% full, corresponding to 90 days at 80GB/day ingest


## AWS Single Instance Humio

For AWS, we recommend starting with these instance types.  This represents
setups that can hold 48h compressed ingest data in RAM; powerful enough to
do a full table scan of ~24h data in less than 10 seconds.

| Instance Type | Daily Ingest | RAM | vCPUs | Notes |
|---------------|--------------|-----|-------|-------|
| `m4.16xlarge` | 600GB        | 256 | 64 (2 CPUs) | run with per-instance cluster
| `m4.10xlarge` | 400GB        | 160 | 40 (2 CPUs) | run with per-instance cluster
| `m4.4xlarge`  | 200GB        | 60  | 16 | single node per instance
| `m4.2xlarge`  | 100GB        | 40  | 8  | single node per instance
| `m2.xlarge`   | 30GB         | 15  | 4  | single node per instance

For multi-socket machines (with multiple physical CPUs), we recommend running
humio as an per-instance cluster, with each Humio node tied to a single
physical CPU.

With EBS storage, you will see query performance drop ~100x when querying beyond
what is loaded into memory caches.

Alternatively, for a little more convenience and performant setup, you can run `i3`
instances which have more RAM, and lets you store the data on local SSDs.  


| Instance Type | Daily Ingest | RAM | vCPUs | Notes |
|---------------|--------------|-----|-------|-------|
| `i3.16xlarge` | 600GB        | 488 | 64 (2 CPUs) | run with per-instance cluster
| `i3.8xlarge`  | 300GB        | 244 | 32 (2 CPUs) | run with per-instance cluster
| `i3.4xlarge`  | 150GB        | 122 | 16 | single node per instance
| `i3.2xlarge`  | 70GB         | 61  | 8  | single node per instance

For instance an `i3.4xlarge` would be suitable for 150GB/day ingest, holding 5 days
of data in cache, and because of the SSDs this would be avoiding the "cliff" when
the cache runs full.  The 3.8TB SSD would hold ~150 days of ingest data.

With ephemeral SSD storage, you'd want to setup EBS instances for live backup (and Kafka's storage),
so that you can load the Humio data onto a fresh machine quickly.  Humio live backup live-replicates all data
to a separate network drive such that data loss is prevented even for ephemeral disks. See [Backup]({{< ref "administration/backup.md" >}}).


## Live Queries / Dashboards

Running many live queries / dashboards is less of an issue with Humio
than most other similar products, because these are kept in-memory as
a sort of in-memory materialized view. The time spent on updating them
is part of the ingest flow and thus having many live queries increase
the cpu usage for the ingest process.  When initializing such queries,
it does need to run a historic query to fill in past data, and that
can take some time in particular if it extends beyond what fits within
the compressed-data in memory horizon.

## Testing disk performance

[FIO](http://git.kernel.dk/cgit/fio/plain/README) is a great tool for
testing the IO performance of your system. It is available as a APT
package on Ubuntu too:

``` shell
sudo apt install fio
```

Run fio either with all options on the command line or through a "jobfile".

```
sudo fio --filename=/data/fio-test.tmp --filesize=1Gi --bs=256K -rw=read --time_based --runtime=5s --name=read_bandwidth_test --numjobs=8 --thread --direct=1
```

Here are a sample contents for a "jobfile" that somewhat mimics how
Humio reads from the file system. Make sure to replace
`/data/fio-tmp-dir` with the path to somewhere on the disk where your
`humio-data` would be located, once installed.

```
[global]
thread
rw=read
bs=256Ki
directory=/data/fio-tmp-dir
direct=1

[read8]
stonewall
size=1Gi
numjobs=8
```

Then run fio
``` shell
fio --bandwidth-log ./humio-read-test.fio
# Clean tmp files from fio:
rm /data/fio-tmp-dir/read8.?.?
```

and then look for the lines at the bottom of the very detailed report similar to...

```
Run status group 0 (all jobs):
   READ: bw=3095MiB/s (3245MB/s), 387MiB/s-431MiB/s (406MB/s-452MB/s), io=8192MiB (8590MB), run=2375-2647msec
```

This example is an NVME providing ~3 GB/s read performance. This
allows for searching up to (9*3) GB/s of uncompressed data if the
system has sufficient number of CPU cores according to the rules of
thumb above. This NVME is well matched to a CPU with 32 hyper-threads
(16 hardware cores.)

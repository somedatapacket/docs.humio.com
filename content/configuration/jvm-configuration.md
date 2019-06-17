---
title: "Java Virtual Machine Configuration"
---

Humio runs on the Java Virtual Machine (JVM).  In this section we briefly describe things you should consider
when selecting and configuring the JVM for Humio.

## Which JVM?

Humio requires a Java version 11 or later JVM to function function properly. At Humio we operate Humio's
[managed offering](https://cloud.humio.com/) using the Azul provided Zulu JVM version 11.  Our Docker container
uses this JVM as well.

We recommend you use one of the following excellent and well tested distributions of the Java JVM runtime when operating
Humio.

### Java Version 11

| Provider                                             | Name                | Architectures |
|------------------------------------------------------|---------------------|---------------|
| [Amazon AWS](https://aws.amazon.com/corretto/)       | OpenJDK 11 Corretto | x86_64        |
| [AdoptOpenJDK.net](https://adoptopenjdk.net/releases.html?variant=openjdk11&jvmVariant=hotspot) | OpenJDK 11 (HotSpot) | x86_64        |
| [Azul Systems](https://www.azul.com/downloads/zulu/) | OpenJDK 11 Zulu     | x86_64        |
| [BellSoft](https://bell-sw.com/pages/java-11.0.2)    | OpenJDK 11 Liberica | x86_64, ARMv8 |
| [Oracle](https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html) | Java SE 11           | x86_64        |
| [Oracle](https://jdk.java.net/archive/)              | OpenJDK 11          | x86_64        |

### Java Version 12

| Provider                                             | Name                | Architectures |
|------------------------------------------------------|---------------------|---------------|
| [Azul Systems](https://www.azul.com/downloads/zulu/) | OpenJDK 12 Zulu     | x86_64        |
| [AdoptOpenJDK.net](https://adoptopenjdk.net/releases.html?variant=openjdk12&jvmVariant=hotspot) | OpenJDK 11 (HotSpot) | x86_64        |
| [BellSoft](https://bell-sw.com/pages/java-12)        | OpenJDK 12 Liberica | x86_64, ARMv8 |

## What about...

 * Azul Zing - While we haven't tried Zing ourselves our experience with Zulu leads us to believe that it is likely to
 work and there may be benefits to using their proprietary, commercially supported C4 concurrent, non-generational
 garbage collector.
 * Graal - Is an interesting alternative C2 HotSpot JIT and native binary compiler for Java programs and
 potentially other languages as well.  It is not yet supported for production use with Humio as it is only available
 for Java version 8.  We plan to investigate and support it as it matures and becomes available for Java 11.

## Java Memory Options

We recommend systems running Humio have as much RAM as possible, but not
for the JVM.  When running Humio it will operate comfortably within 10 GiB
for most workloads. The remainder of your RAM in the system should remain
available for use as filesystem page cache.

A good rule of thumb calculation for memory allocation is as follows:

(8GB baseline + 1GB per core) + that much again in off-heap memory

So, for a production installation on an 8 core VM, you would want about
64GB of memory with JVM settings as follows:

```bash
-server -Xms16G  -Xmx16G -Xss2M -XX:MaxDirectMemorySize=16G
```

This sets Humio to allocate a heap size of 16GB and further allocates
16GB for direct memory access (which is used by direct byte buffers).
That will leave a further 32GB of memory for OS processes and filesystem
cache. For large installations, more memory for filesystem cache to use
will translate into faster queries, so we recommend using as much memory
as is economically feasible on your hardware.

For a smaller, 2 core system that would look like this:

```bash
-server -Xms10G  -Xmx10G -Xss2M -XX:MaxDirectMemorySize=10G
```

That sets Humio to allocate a heap size of 10GB and further allocates
10GB for direct memory access (as such, you would want a system with
32GB of memory, most likely).

It's definitely possible to run Humio on smaller systems with less memory
than this, but we recommend a system with at least 32GB of memory for all
but the smallest installations.

{{% notice note %}}
To view how much memory is available for use as filesystem page cache, you
can run the following command:

```bash
$ free -h
              total        used        free      shared  buff/cache   available
Mem:           125G         24G        1.7G        416K         99G         99G
Swap:           33G         10M         33G
```

The memory displayed in the `available` column is what's currently available
for use as page cache. The `buff/cache` column displays how much of that memory
is currently being used for page cache.
{{% /notice %}}

## Garbage Collection

Humio has been tested and run using the Garbage First (`-XX:+UseG1`)
and the old parallel (`-XX:+UseParallelOldGC`) collectors.  Both work
quite well with our standard workload. The preference is for
throughput rather than for low latency: Humio has been optimized to
avoid allocations as much as possible and is thus better suited for
garbage collectors that add little overhead to the running code
(i.e. don't add extra read or write barriers) than those that accept
the overhead in return for lower latency.

We have discovered that the ZGC reserves memory as "shared memory" which has the effect of lowering the amount available
for disk caching.  As Humio is generally IO bound the ability to cache as much of the block device into RAM is related
to providing lower latency and higher throughput.  We recommend against using the ZGC until we have tested the
implications of the [JEP 351](https://openjdk.java.net/jeps/351) which we hope addresses this issue.

Regardless of which collector you use we recommend that you configure the JVM for verbose garbage collector logging and
then store and monitor those logs within Humio itself.

```bash
-Xlog:gc+jni=debug:file=/var/log/humio/gc.log:time,tags:filecount=5,filesize=102400
```

It can be helpful to request that the JVM attempt to do a bit of scavenging before stopping the entire JVM for a
full collection.

```bash
-XX:+ScavengeBeforeFullGC -XX:+DisableExplicitGC
```

## Verify Physical Memory is Available for Filesystem Page Cache

Once you have Humio (and perhaps also Kafka, Zookeeper and other software) running on your server, verify that there is
ample memory remaining for caching files using the command `free -h`. On a server with e.g. 128 GB of RAM we usually
see around 90 GB as "available".  If the number is much lower, due to a large amount being either "used" or "shared",
then you may want to improve on that.
 
However if you have a very fast IO subsystem, such one based on a RAID 0 stripe of fast NVMe drives, where you may find
that using memory for caching has no effect on query performance.

You can check by dropping the OS file cache using `sudo sysctl -w vm.drop_caches=3` which will drop any cached files,
and then compare the speed when running the same trivial query multiple times.  Using the same fixed time interval,
query of a simple `count()` twice on a set of data that makes the query take 5-10 seconds to execute is a good test.
If you benefit from the page cache you will see a much faster response on the second and following runs compared to the
first run.

Another way to validate that the IO subsystem is fast is to inspect the output of `iostat -xm 2` while running a query
after dropping filesystem page cached data as shown above.  If the NVMe-drives are close to a 100% utilized, then you
will benefit from having memory for page caching.

## Helpful Java/JVM Resources

 * [Java JVM Options Explorer](https://chriswhocodes.com/hotspot_options_jdk11.html)
 * [Java GC Logging options](https://www.slideshare.net/PoonamBajaj5/lets-learn-to-talk-to-gc-logs-in-java-9)
 * [AdoptOpenJDK APT, RPM, YUM](https://medium.com/adoptopenjdk/adoptopenjdk-rpm-and-deb-files-7003ba38144e)
 * [BellSoft APT, RPM, YUM](https://apt.bell-sw.com/)

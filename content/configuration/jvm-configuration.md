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

## Java Options

We recommend systems running Humio have as much RAM as possible, but not for the JVM.  When running Humio it will
operate comfortably within 10 GiB for most workloads.  The remainder of your RAM in the system should remain available
for use as filesystem buffers.

```bash
-server -Xms10g  -Xmx10g -Xss2M -XX:MaxDirectMemorySize=32G -XX:+AlwaysPreTouch
```

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

## Verify Physical Memory is Available for Filesystem Buffer Cache

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
after dropping filesystem buffer cached data as shown above.  If the NVMe-drives are close to a 100% utilized, then you
will benefit from having memory for page caching.

## Helpful Java/JVM Resources

 * [Java JVM Options Explorer](https://chriswhocodes.com/hotspot_options_jdk11.html)
 * [Java GC Logging options](https://www.slideshare.net/PoonamBajaj5/lets-learn-to-talk-to-gc-logs-in-java-9)

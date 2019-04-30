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

Humio has been tested and run using the Garbage First (`-XX:+UseG1`) and the old parallel (`-XX:+UseParallelOldGC`)
collectors.  Both work quite well with our standard workload.

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

## A note on NUMA (multi-socket) systems

NUMA aware JVM will partition the heap with respect to the NUMA nodes, and when a thread creates a new object, the
object is allocated in the NUMA node of the core that runs that thread (if the same thread later uses it, the object
will be in the local memory). Also when compacting the heap the NUMA aware JVM avoids moving large data chunks between
nodes (and reduces the length of stop-the-world events).

So on any NUMA hardware and for any Java application the `-XX:+UseNUMA` option should be enabled.

[JEP 345](https://openjdk.java.net/jeps/345): [NUMA-Aware Memory Allocation for G1](https://bugs.openjdk.java.net/browse/JDK-8210473) is `Unresolved`

Shenandoah does not support NUMA and the ZGC has only [basic NUMA support](https://wiki.openjdk.java.net/display/zgc/Main) and [is enabled by default on multi-socket systems](https://wiki.openjdk.java.net/display/zgc/Main#Main-EnablingNUMASupport) or can be explicitly requested with the `-XX:+UseNUMA` option.

The parallel collector (enabled by by -XX:+UseParallelGC) has been NUMA-aware for many years

Humio fully utilizes the available IO channels, physical memory and CPU during query execution.  Coordinating memory
accross cores can slow Humio down.  We recommend that a single JVM be run on each separate CPU (socket, not core) and
that you instruct the operating system that the process should remain on that socket using only memory most tightly
bound to it.  On Linux you can use the `numactl` executable to do this.

```-XX:+UseNUMA```

```bash
/usr/bin/numactl --cpunodebind=%i --membind=%i
``` 

## Helpful Java/JVM Resources

 * [Java JVM Options Explorer](https://chriswhocodes.com/hotspot_options_jdk11.html)
 * [Java GC Logging options](https://www.slideshare.net/PoonamBajaj5/lets-learn-to-talk-to-gc-logs-in-java-9)

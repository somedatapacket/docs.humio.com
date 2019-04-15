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

Humio has been tested and run using the Garbage First (G1) and the Z collectors.  Both work quite well with our standard
workload.  The Z collector is now standard in Java 11 and you can enable it with `-XX:+UseZGC`.  This is the collector
we use in our docker configuration and run on our managed offering.

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

At this time we recommend using the Garbage First collector in production (`G1GC`), however as of Java 12 there will be two fully concurrent, non-generational collectors with excellent potential for Humio workloads:

 * [Z Garbage Collector](https://wiki.openjdk.java.net/display/zgc/Main) included with most OpenJDK 11 builds and
 * [ShenandoahGC](https://wiki.openjdk.java.net/display/shenandoah/Main) included in Liberica, Zulu and on RedHat in Java 12 or for download [here](https://builds.shipilev.net/openjdk-shenandoah-jdk11/) from the team who did the implementation.

To use these collectors replace `-XX:+UseG1GC` with either:

 * `-XX:+UseZGC` or
 * `-XX:+UnlockExperimentalVMOptions -XX:+UseShenandoahGC`

## Helpful Java/JVM Resources

 * [Java JVM Options Explorer](https://chriswhocodes.com/hotspot_options_jdk11.html)
 * [Java GC Logging options](https://www.slideshare.net/PoonamBajaj5/lets-learn-to-talk-to-gc-logs-in-java-9)

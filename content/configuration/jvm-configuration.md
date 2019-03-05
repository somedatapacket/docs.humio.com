---
title: "Java Virtual Machine Configuration"
---

Humio runs on the Java Virtual Machine (JVM).  In this section we briefly describe things you should consider
when selecting and configuring the JVM for Humio.

## Which JVM?

While Humio is supported on Java 1.9 we recommend using Java 11 and of the many excellent and well tested distributions
of the Java JVM runtime we test and recommend the use of one of these:

### Java Version 1.9

| Provider                                             | Name                | Architectures |
|------------------------------------------------------|---------------------|---------------|
| [Azul Systems](https://www.azul.com/downloads/zulu/) | OpenJDK 9 Zulu      | x86_64        |
| [Oracle](https://jdk.java.net/archive/)              | OpenJDK 9           | x86_64        |
| [AdoptOpenJDK.net](https://adoptopenjdk.net/releases.html?variant=openjdk9&jvmVariant=hotspot)  | OpenJDK 9 (HotSpot)  | x86_64        |

### Java Version 11

| Provider                                             | Name                | Architectures |
|------------------------------------------------------|---------------------|---------------|
| [Oracle](https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html) | Java SE 11           | x86_64        |
| [Oracle](https://jdk.java.net/archive/)              | OpenJDK 11          | x86_64        |
| [Amazon AWS](https://aws.amazon.com/corretto/)       | OpenJDK 11 Corretto | x86_64        |
| [Azul Systems](https://www.azul.com/downloads/zulu/) | OpenJDK 11 Zulu     | x86_64        |
| [BellSoft](https://bell-sw.com/pages/java-11.0.2)    | OpenJDK 11 Liberica | x86_64, ARMv8 |
| [AdoptOpenJDK.net](https://adoptopenjdk.net/releases.html?variant=openjdk11&jvmVariant=hotspot) | OpenJDK 11 (HotSpot) | x86_64        |


At Humio we operate Humio's [hosted offering](https://cloud.humio.com/) using the Azul provided Zulu JVM
version 11 as it is well tested, maintained and stable OpenJDK distribution.  We are also very impressed with the
BellSoft provided Liberica distribution and are happy to see it support ARMv8 as well as Intel CPUs.


## What about...

 * IBM/OpenJ9 - The OpenJDK build called "OpenJ9" is known *not* to work properly at this time, we are investigating and hope to include it as a supported JVM in the future.
 * Azul Zing - While we haven't tried Zing ourselves our experience with Zulu leads us to believe that it is likely to work and there may be benefits to using their proprietary, commercially supported C4 concurrent, non-generational garbage collector.
 * Oracle Graal - Is an interesting alternative C2 HotSpot JIT and native binary compiler for Java programs and potentially other languages as well.  It is not yet supported for production use with Humio as it is only available for Java feature level 8.  We plan to investigate and support it as it matures and becomes available for Java 11.
 * Java 12 - We have yet to test and certify Humio on any Java 12 JVM however we plan to do this soon after it becomes generally available.

## Garbage Collection

Here are some sample configurations.  We have seen good results running the G1 collector in production here shown with a 10GiB heap.
This configuration works on Java 9 or 11.
```bash
java -server -Xms10g  -Xmx10g -XX:+AlwaysPreTouch -XX:+UseG1GC -XX:+ScavengeBeforeFullGC -XX:+DisableExplicitGC
```

At this time we recommend using the Garbage First collector in production (`G1GC`), however as of Java 12 there will be two fully concurrent, non-generational collectors with excellent potential for Humio workloads:
* [Z Garbage Collector](https://wiki.openjdk.java.net/display/zgc/Main) included with most OpenJDK 11 builds and
* [ShenandoahGC](https://wiki.openjdk.java.net/display/shenandoah/Main) included on RedHat or available for download [here](https://builds.shipilev.net/openjdk-shenandoah-jdk11/).

To use these collectors replace `-XX:+UseG1GC` with either `-XX:+UseZGC` or `-XX:+UseShenandoahGC` and be sure to include `-XX:+UnlockExperimentalVMOptions`.

## Helpful Java/JVM Resources

* [Java JVM Options Explorer](https://chriswhocodes.com/hotspot_options_jdk11.html)

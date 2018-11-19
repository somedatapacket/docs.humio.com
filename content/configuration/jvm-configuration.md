---
title: "Java Virtual Machine Configuration"
---

Humio runs on the Java Virtual Machine (JVM).  In this section we briefly describe things you should consider
when selecting and configuring the JVM for Humio.

## Which JVM?

Humio runs on feature version 9 or 11 of a few well known JVM distributions.  It may function perfectly well
on others, however we recommend one of these:

| Feature Level            | Provider                                                   |
|--------------------------|------------------------------------------------------------|
| `9`, or `1.9`            | [Azul Systems](https://www.azul.com/downloads/zulu/) OpenJDK 9 Zulu certified build
| `9`, or `1.9`            | [Oracle](https://jdk.java.net/archive/) OpenJDK 9
| `9`, or `1.9`            | [AdoptOpenJDK.net](https://adoptopenjdk.net/releases.html?variant=openjdk9&jvmVariant=hotspot) OpenJDK 9 (HotSpot)
| `11`                     | [Oracle](https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html) Java SE 11
| `11`                     | [Oracle](https://jdk.java.net/archive/) OpenJDK 11
| `11`                     | [Azul Systems](https://www.azul.com/downloads/zulu/) OpenJDK 11 Zulu certified build
| `11`                     | [AdoptOpenJDK.net](https://adoptopenjdk.net/releases.html?variant=openjdk11&jvmVariant=hotspot) OpenJDK 11 (HotSpot)

We develop and run Humio using the Azul provided Zulu JVM version 11 and find it to be a stable well maintained OpenJDK distribution.

What about:
* IBM/OpenJ9 - The OpenJDK build called "OpenJ9" is known not to work properly at this time, we are investigating and hope to include it as a supported JVM in the future.
* Corretto - Amazon is now providing an OpenJDK distribution called "Corretto" which currently only ships with feature level 8 (1.8) and is not supported at this time.
* Azul Zing - While we haven't tried Zing ourselves our experience with Zulu leads us to believe that it is likely to work and there may be benefits to using their C4 concurrent GC.
* Oracle Graal - Is an interesting alterntiave C2 compiler for OpenJDK-based JVMs but is not yet supported for use with Humio as it is only available for Java feature level 8 (1.8).

## Garbage Collection

Here are some sample configurations.  We have seen good results running the G1 collector in production here shown with a 10GiB heap.
This configuration works on Java 9 or 11.
```bash
java -server -Xms10g  -Xmx10g -XX:+AlwaysPreTouch -XX:+UseG1GC -XX:+ScavengeBeforeFullGC -XX:+DisableExplicitGC
```

As of Java 11 there are two fully concurrent, non-generational collectors with excellent potential for Humio workloads:
* [Z Garbage Collector](https://wiki.openjdk.java.net/display/zgc/Main) included with most OpenJDK 11 builds and
* [ShenandoahGC](https://wiki.openjdk.java.net/display/shenandoah/Main) included on RedHat or available for download [here](https://builds.shipilev.net/openjdk-shenandoah-jdk11/).

To use these collectors replace `-XX:+UseG1GC` with either `-XX:+UseZGC` or `-XX:+UseShenandoahGC` and be sure to include `-XX:+UnlockExperimentalVMOptions`.
-XX:+UseShenandoahGC

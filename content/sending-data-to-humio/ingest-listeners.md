---
title: "Ingest Listeners"
weight: 1
featured-on: ["on-prem"]
---

Ingest Listeners is a great way of shipping data to Humio through raw sockets, via either UDP or TCP. Example use cases are

* syslog
* [StatsD]({{< ref "integrations/data-shippers/statsd" >}})

An Ingest listener binds a UDP or TCP port on an network interface to a repository with a [parser]({{< ref "parsers" >}}). Meaning that all data sent to a network port will be parsed up with a parser before it's inserted into the repository.

## List of Ingest listeners

Go to the **Ingest Listeners** subpage in your repository's settings page to see a list of already configured Ingest Listeners. For a new installation this list will be empty.

{{% figure src="/images/ingest-listeners-settings.png" %}}

In the upper right hand corner there's a button for [creating a new ingest listener]({{< ref "#creating-ingest-listeners" >}})

## Creating ingest listeners

Creating a new ingest listener is all about mapping a port on a network interface through a parser to a repository. Selecting **Add Ingest Listener** will present you with the following form:

{{% figure src="/images/create-ingest-listener.png" width="300px" %}}

The ingest listener needs the following details

* **Name** a name usually describing the purpose of the ingest listener.
* **Protocol** Transport protocol for the ingest listener. This can be one of TCP, UDP or Netflow/UDP.
* **Parser** A [parser]({{< ref "parsers" >}}) to send each line on the socket through to extract fields from the line. Usually a timestamp. Netflow/UDP does not need a parser it has a rather complex syntax.
* **Port** Network port to accept data. Note that you are not running your Docker images with `--net=host` this port needs to be exposed via `--publish` Docker argument
* **Bind interface** The ip of the interface that this ingest listener should listen on.
* **Charset** The charset used to decode the event stream. The value must be a supported Charset in the JVM that Humio is running on.

### Reducing packet loss from bursts on UDP
To reduce packet loss in bursts of UDP traffic, please increase the maximum allowed receive buffer size for UDP.
Humio will try to increase the buffer to up to 128MB, but will accept whatever the system sets as maximum.

```shell
# Get the current limit from the kernel (in bytes)
sysctl net.core.rmem_max
# Set to 16MB. Decide on a value of (say) 0.1 - 1 seconds worth of inbound UDP packets.
sudo sysctl net.core.rmem_max=16777216
```

Note that this change needs to happen before Humio is started. You
probably want it done when the system boots. On Debian (e.g. Ubuntu)
you can achiveve this by creating a file in `/etc/sysctl.d/` with a
name such as `raise_rmem_max.conf` and the contents

```
net.core.rmem_max=16777216
```

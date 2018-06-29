---
title: Bare Metal
slug: installation-on-bare-metal
weight: 500
---

If you want to run Humio directly from the Jar file you will need to provide
your own **Kafka** and **Zookeeper** instances.

## External Dependencies

- Kafka
- Zookeeper
- JVM version 9 or above.

## Setup

Please refer to the [Ansible reference project](https://github.com/humio/ansible-humio) for setting
up Humio on your system.  
The project contains uses all the [configuration options]({{< ref "configuration/_index.md" >}})
needed to connect to Kafka, Zookeeper and optionally run Humio as a cluster.

### Resources

- [Ansible reference project](https://github.com/humio/ansible-humio)
- [Example Provisioning Scripts](https://github.com/humio/provision-humio-cluster)

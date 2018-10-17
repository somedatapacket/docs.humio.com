---
title: Ansible
pageImage: /integrations/ansible.svg
icon: /integrations/ansible-logo.svg
weight: 300
categories: ["Integration", "Platform"]
categories_weight: 200
---

Ansible is a great way of managing a Humio cluster. Therefor we have provided a list of Ansible Galaxy roles, plus a few sample projects that demonstrates how they are used.

## Ansible Galaxy Roles

At this point we are actively maintaining the following three Roles

* [humio.java](https://galaxy.ansible.com/humio/java)
* [humio.kafka](https://galaxy.ansible.com/humio/kafka)
* [humio.server](https://galaxy.ansible.com/humio/server)

Additionally we recommend using the following roles as well

* [AnsibleShipyard.ansible-zookeeper](https://galaxy.ansible.com/AnsibleShipyard/ansible-zookeeper)
* [Ansible beats](https://github.com/elastic/ansible-beats)

At this point we will not go too much into details about how to configure these roles other than explaining the purpose of each role, but refer to our sample projects which should inspire a firm configuration.

* [Packet.net](https://github.com/humio/ansible-demo/tree/master/packet_net)
* [AWS EC2](https://github.com/humio/ansible-demo/tree/master/aws_ec2)

The easiest way to refer to these roles is using a `requirements.yml` file in the root of your Ansible project

```yamlex
- src: humio.java
- src: AnsibleShipyard.ansible-zookeeper
- src: humio.kafka
- src: humio.server
- src: https://github.com/elastic/ansible-beats
```

Install the roles with a simple

```bash
ansible-galaxy install --role-file=requirements.yml
```

### humio.java
Both Zookeeper, Kafka and Humio require Java. The purpose of this role is to install [Azul Zulu OpenJDK](https://www.azul.com/products/zulu-enterprise/).
It has sensible defaults so no extra configuration is required.

### AnsibleShipyard.ansible-zookeeper
This is a third-party role that we have a good experiences with.
Configuring can be a bit cumbersome but unfortunately that's the nature of Zookeeper. At least the following variables should be configured for the Zookeeper role

* `zookeeper_hosts`, array consisting of objects containing
  * `id`, the Zookeeper host id, usually a number between 1 and 3
  * `host`, the ip address of the host

There are several options for automating this list, please see the [Cluster example](https://github.com/AnsibleShipyard/ansible-zookeeper#cluster-example).

We recommend having at least 3 Zookeeper nodes for high-availability.

### humio.kafka
Kafka is in the heart of a Humio. Although the use of this exact role isn't strictly necessary, it's highly recommended since the Humio team will be maintaining sensible configuration defaults for Kafka.

For performance it is a good idea to have one kafka instance per [Humio server](#humio-server) in your cluster.

The configuration of the role is very much similar to [Zookeeper](#ansibleshipyard-ansible-zookeeper), with only a few required variables

* `kafka_broker_id`, a unique number identifying the instance
* `zookeeper_hosts`, exactly similar to the same variable in the [Zookeeper role](#ansibleshipyard-ansible-zookeeper)

For more details on configuration, please take a look at the [GitHub repository](https://github.com/humio/ansible-kafka)

### humio.server

The purpose of the `humio.server` role is to install the Humio server itself.

Again, the configuration of the role is pretty similar to the [Zookeeper](#ansibleshipyard-ansible-zookeeper) and [Kafka](#humio-kafka) roles, with only a few required variables

* `zookeeper_hosts`, exactly similar to the same variable in the [Zookeeper role](#ansibleshipyard-ansible-zookeeper)
* `kafka_hosts`, exactly similar to the same variable in the [Kafka role](#humio-kafka)

Next to that, we recommend maintaining the `humio_version` variable as not all update paths are free of side-effects.

For more details on configuration, please take a look at the [GitHub repository](https://github.com/humio/ansible-server)

### Ansible beats
This is a third-party role maintained by the people behind the Beat shippers, Elastic Inc. Unfortunately, at this point it's not pushed to Ansible Galaxy as an official role.

The configuration of the role is pretty straightforward but we strongly recommend reading it's [documentation](https://github.com/elastic/ansible-beats/)

We recommend the following configuration on Humio nodes
```yamlex
- role: "ansible-beats"
  beat: "filebeat"
  beat_conf:
    "filebeat":
      "inputs":
        - paths:
            - /var/log/humio/*/humio-debug.log
            fields:
              "@type": humio
              "@tags": ["@host", "@type"]
            multiline:
              pattern: '^[0-9]{4}-[0-9]{2}-[0-9]{2}'
              negate: true
              match: after
        - paths:
            - /var/log/kafka/server.log
            fields:
              "@type": kafka
              "@tags": ["@host", "@type"]
            multiline:
              pattern: '^\[[0-9]{4}-[0-9]{2}-[0-9]{2}'
              negate: true
              match: after
      output_conf:
        "elasticsearch":
          "hosts": ["localhost"]
          "username": "developer" //Don't forget to replace this with a real ingest token
```
---
title: "Installation"
weight: 90
category_title: Installation Overview
---

Humio is available for [download](https://www.humio.com/download) or as [SaaS](https://cloud.humio.com/).
If you choose to host your own Humio instance, there are two primary ways of installing it:

- Running it in a Docker container
- or running as a Jar file

If you are just getting started with Humio, we recommend running Humio as a Docker container since
it contains the external dependencies needed, i.e. Kafka and Zookeeper. If you plan on
running Humio on bare metal please refer to our [Bare Metal Installation Guide]({{< ref "bare-metal.md" >}}).

## Guides

<!-- - Running Humio on Kubernetes -->
- [Running in Docker]({{< ref "docker.md" >}})
- [Running on Bare Metal]({{< ref "bare-metal.md" >}})
- [Provisioning with Ansible]({{< ref "ansible.md" >}})
- [Running on AWS]({{< ref "aws.md" >}})
- [Running on Nomad]({{< ref "nomad.md" >}})

## Hardware Requirements

Hardware requirements depend Humio will be used, both how much data you will be
ingesting and how many concurrent searches you will be running.

Here is a list of *rules of thumb* to help you get an idea of how much hardware is needed.

### Estimating Resources

1. Assume data compresses 6x on ingest (test your setup and see, better compression means better performance).
1. You need to be able to hold 48hrs of compressed data in 80% of you RAM.
1. You want enough hyper-threads/vCPUs (each giving you 1GB/s search) to be able
   to search 24hrs of data in less than 10 seconds.
1. You need disk space to hold your compressed data. Never fill your disk more than 80%.

**Example Setup**  
Your machine has 64G of ram, and 8 hyper threads (4 cores), 1TB of storage.
Your machine can hold 307GB of ingest data compressed, and process 8GB/s.  In this case
that means that 10 seconds worth of query time will run through 80G of data.  So this machine
fits an 80G/day ingest, with +3 days data available for fast querying.  
You can store 4.8TB of data before your disk is 80% full, corresponding to 60 days.  

For more details refer to our [Instance Sizing Reference]({{< ref "instance_sizing.md" >}}).

## Cluster Setup

Humio was made to scale and scales very well with the number of nodes in the cluster.
If you want to run a clustered mode please refer to [cluster setup]({{< ref "cluster_setup.md" >}}).

## Configuration Options

Please refer to the [configuration reference page]({{< ref "configuration/_index.md" >}}).

---
title: "Documentation Overview"
---

# Documentation Overview

Humio is a fast and flexible logging platform. It is available for self-hosting or as SaaS.
Humio is compatible with most popular open-source log shippers (Fluentd, Rsyslog, FileBeat, etc.)
so it is easy to adopt or migrate to from other platforms like ElasticSearch ELK.
The simple yet powerful query language feels familiar to most developers,
and works on any data format - structured or unstructured.

Humio keeps the cost of data ingestion low, and uses heavy compression for data at rest.
This allows you to _log and keep everything_ for optimal observability, without punishing you
for data spikes or having growing data volumes.

The REST API and snappy graphical user interface allows you to search, transform and observe
events as they occur – in Real-Time. And when we say real-time, we mean sub-second delays
from data arriving for ingestion before it is displayed on a live dashboard.

Finally, built-in support for alerting and integrations with popular operations platforms (like
PageDuty, OpsGene or VictorOps) means Humio can be the backbone of your operations infrastructure,
a power tool for your help-desk teams and your trusted navigator on an ocean of data.


_If you are new to log management the [introduction to log management]({{< relref "intro_to_log_management.md" >}})
will help you get to grips with the core concepts is and where Humio fits in to the logging ecosystem._


## Getting Started with Humio


You have two option for getting started with Humio, [downloading](https://www.humio.com/download/)
and running it yourself, or creating a free account in [Humio Cloud](https://cloud.humio.com/).

{{< figure src="pages/welcome/eggs.svg" width="180px" >}}

### 1. Working with Logs

The first thing you should do once you have a running instance we recommend you go through the in-app tutorial
that teaches you the basics of searching. You can find the tutorial in the _Help_ menu at the top of the UI.
The tutorial simulates log data from a web server and steps you through searching and visualizing the logs.

### 2. Pick a Repository

While simulated data is all well and good, you only feel the real power of Humio once
you can work with your own data. It is time to start sending logs to Humio.
There are several options for getting data into Humio.

#### 2.1 Choose a Repository

No matter what you choose, you will first need to pick which [repository]({{< relref "repositories.md" >}})
to store the data in. If you are on a free Cloud account you will use your [sandbox repository]({{< relref "the_sandbox.md" >}}).
If you are running Humio yourself, you can either use your sandbox or create a new dedicated repository.

#### 2.2 Find your Ingest Token

Once you have chosen a repository you need get an access token called an [ingest token]({{< relref "ingest_tokens.md" >}}).
You can find the _default_ ingest token generated for your repository by going to:

`Repository` __→__ `Settings` __→__ `Ingest Tokens`

and copying the default token (or creating a new one).

#### 2.3 Send Logs

Now you are all set, choose one of the following options:

- Configure a log-shipper (Rsyslog, FileBeat, Logstash, etc.),
- Use one of our platform integration (Kubernetes, Docker, DC/OS, etc.)
- or ingest through Humio's REST API

_Tip: If you are already using ElasticSearch ELK you can also take a look at how easy it is to
[migrate from an Elastic Stack]({{< relref "moving_from_elastic_stack.md" >}}) to Humio._

### 3. Next Steps

- [Query Function Reference]({{< relref "query_functions.md" >}})
- [Creating Custom Parsers]({{< relref "" >}})
- [Virtual Repositories]({{< relref "" >}})
- [Controlling Retention]({{< relref "" >}})

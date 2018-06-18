---
title: "Root"
---

# Documentation Overview

Humio is a fast and flexible logging platform. It is available for self-hosting or as SaaS.
Humio is compatible with most popular open-source data shippers (Fluentd, Rsyslog, FileBeat, etc.)
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

## Integrations

<div class="integration-overview">
  <div class="integration-overview__section">
    <h3 class="integration-overview__section-title">Data Shippers</h3>
    <ul>
      <li><a href="{{% ref "filebeat.md" %}}">Filebeat</a></li>
      <li><a href="{{% ref "logstash.md" %}}">Logstash</a></li>
      <li><a href="{{% ref "rsyslog.md" %}}">Rsyslog</a></li>
      <li><a href="{{% ref "sending-data/data-shippers/_index.md" %}}">List All</a></li>
    </ul>
  </div>
  <div class="integration-overview__section">
    <h3 class="integration-overview__section-title">Platforms</h3>
    <ul>
      <li>Kubernetes</li>
      <li>Cloudwatch</li>
      <li>Mesos & DC/OS</li>
      <li>List All</li>
    </ul>
  </div>
  <div class="integration-overview__section">
    <h3 class="integration-overview__section-title">Languages & Frameworks</h3>
    <ul>
      <li>Python</li>
      <li>Erlang & Elixir</li>
      <li>NodeJS</li>
      <li>List All</li>
    </ul>
  </div>
</div>

## Getting Started

Before we can get started you need to have access to a running Humio instance.
You have two option. You can [download](https://www.humio.com/download/)
and running it yourself, or creating a free account in [Humio Cloud](https://cloud.humio.com/).

{{< figure src="pages/welcome/eggs.svg" width="180px" >}}

<p align="center" style="margin-bottom: 40px;">
{{% button href="https://www.humio.com/download/" icon="fa fa-download" %}}Download Humio{{% /button %}}
{{% button href="https://cloud.humio.com/" icon="fa fa-cloud" %}}Free Cloud Account{{% /button %}}
</p>

Once you have access to running Humio instance, you can head over to
the [Hello World]({{< ref "tutorial/_index.md" >}}) tutorial.

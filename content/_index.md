---
title: "Front Page"
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


_If you are new to log management the [introduction to log management]({{< ref "intro_to_log_management.md" >}})
will help you get to grips with the core concepts is and where Humio fits in to the logging ecosystem._

## Integrations

<a href="{{% ref "integrations/_index.md" %}}">Full List of Integrations</a>

<div class="integration-overview">
  <div class="integration-overview__section">
    <h5 class="integration-overview__section-title">Popular Data Shippers</h5>
    {{% integration-selection "datashipper" 4 %}}
  </div>
  <div class="integration-overview__section">
    <h5 class="integration-overview__section-title">Popular Platforms</h5>
    {{% integration-selection "platform" 4 %}}
  </div>
  <div class="integration-overview__section">
    <h5 class="integration-overview__section-title">Other Integrations</h5>
    {{% integration-selection "otherintegration" 4 %}}
  </div>
</div>

## Getting Started

Before we can get started you need to have access to a running Humio instance.
You have two option. You can [download](https://www.humio.com/download/)
and run it yourself or creating a free account in [Humio Cloud](https://cloud.humio.com/).

{{< figure src="pages/welcome/eggs.svg" width="180px" >}}

<p align="center" style="margin-bottom: 40px;">
{{% button href="https://www.humio.com/download/" icon="fa fa-download" %}}Download Humio{{% /button %}}
{{% button href="https://cloud.humio.com/" icon="fa fa-cloud" %}}Free Cloud Account{{% /button %}}
</p>

Once you have access to running Humio instance, you can head over to
the [tutorial]({{< ref "tutorial/_index.md" >}}).

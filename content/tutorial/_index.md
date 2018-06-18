---
title: "Tutorial"
category_title: "Hello World"
weight: 95
---

This tutorial will teach you search and send data to Humio.
Before we get started make sure you have a running installation of Humio or
a free Humio Cloud account:

{{< figure src="/pages/welcome/eggs.svg" width="180px" >}}

<p align="center" style="margin-bottom: 40px;">
{{% button href="https://www.humio.com/download/" icon="fa fa-download" %}}Download Humio{{% /button %}}
{{% button href="https://cloud.humio.com/" icon="fa fa-cloud" %}}Free Cloud Account{{% /button %}}
</p>

## 1. Learning to Search

The first thing you should do once you have a running instance is to go through
the interactive in-app tutorial.
It is a 101-course that teaches you the basics of searching. You can find the
tutorial in the __Help__ menu at the top of the UI:

`Help` __→__ `Interactive Tutorial`

While the tutorial panel is open it will continuously stream simulated log data
from a web server and steps you through searching and visualizing the logs.

{{< figure src="/pages/hello-world/docs-hello-world-tutorial.png" >}}

Once you have completed the tutorial move on to [step 2]({{< ref "#step-2" >}}).

{{% notice tip %}}
You can use the UI's build-in function documentation by hitting {{% keybinding "alt+enter" %}} while
focusing the search field. We also have documentation and examples for all
functions in the [query function reference]({{< relref "query-functions/_index.md" >}}).
{{% /notice %}}


## 2. Preparing a Repository {#step-2}

While simulated data is all well and good, you only feel the real power of Humio once
you can work with your own data. It is time to start sending logs to Humio.

### 2.1 Sandbox or Dedicated Repository

First you need a [repository]({{< ref "repositories.md" >}}) to store the data in.
You can either use your [sandbox repository]({{< ref "the-sandbox.md" >}}) or if you are running Humio
locally you can create a new dedicated repository (make sure to pick a "Repository"
and not "View" since they cannot be used for storage).

{{< figure src="/pages/hello-world/new-repo.png" >}}

### 2.2 Find your Ingest Token

Once you have chosen a repository you need get an access token called an [ingest token]({{< relref "ingest_tokens.md" >}}).
You can find the _default_ ingest token generated for your repository by going to:

`Settings` __→__ `Ingest Tokens` __→__ `Click the Eye Icon`

and copying the default token (or creating a new one).

{{< figure src="/pages/hello-world/ingest-token.png" title="Getting the default ingest token from your repository." >}}


### 3. Choosing a Parser

When data arrive at Humio they need to be parsed. Therefore you have to specify
which parser should be used to interpret your data. Which one your need depends
your data format. A safe bet is the `kv` (Key-Value) parser.

It looks at incoming events and finds `key=value` pairs - producing a field `key`
with the value `"value"` on the stored event.

You can go to the "Parsers" menu item in the top menu of the UI to explore. But
for now, it is a good idea to stick with one of the built-in parsers for your first
experiments with Humio.


### 4. Sending Data

Now you are all set, choose one of the following guides:

- [Configure a log-shipper (Rsyslog, FileBeat, Logstash, etc.)]({{< relref "sending-data/data-shippers/_index.md" >}}),
- [Use one of our platform integration (Kubernetes, Docker, DC/OS, etc.)]({{< relref "sending-data/integrations/_index.md" >}}),
- [or ingest through Humio's REST API]({{< relref "ingest-api.md" >}})

_Tip: If you are already using ElasticSearch ELK you can also take a look at how easy it is to
[migrate from an Elastic Stack]({{< relref "moving_from_elastic_stack.md" >}}) to Humio._

#### 4.1 Extra: Custom Parsers

While Humio has build-in support for the most popular logging formats (e.g. AccessLog, JSON)
and can rip out almost anything with the `kv` <!-- TODO: Missing Link --> parser, you still
may have special needs for your custom application logs. If that is the case you need to
[create your own custom parser]({{< relref "parsing.md" >}}).

## 5. Next Steps

- [Query Function Reference]({{< relref "query-functions/_index.md" >}})
- [Creating Custom Parsers]({{< relref "parsing.md" >}})
- [Virtual Repositories]({{< relref "views.md" >}})
- [Controlling Retention]({{< relref "retention.md" >}})

---
title: "Tutorial"
weight: 95
aliases: ["getting_started", "getting_started/tutorial"]
---

This tutorial will teach you how to search and send data to Humio.
Before we get started, make sure you have a running installation of Humio or
a free Humio Cloud account:

{{< figure src="/pages/welcome/eggs.svg" width="180px" >}}

<p align="center" style="margin-bottom: 40px;">
{{% button href="https://www.humio.com/download/" icon="fa fa-download" %}}Download Humio{{% /button %}}
{{% button href="https://cloud.humio.com/" icon="fa fa-cloud" %}}Free Cloud Account{{% /button %}}
</p>

## 1. Learning to Search

Once you have a running instance, go through
the interactive in-app tutorial.
It is a 101-course that teaches you the basics of searching. You can find the
tutorial in the __Help__ menu at the top of the UI:

`Help` __→__ `Interactive Tutorial`

While the tutorial panel is open it will continuously stream simulated log data
from a web server and step you through searching and visualizing the logs.

{{< figure src="/pages/hello-world/docs-hello-world-tutorial.png" >}}

Once you have completed the tutorial move on to [step 2]({{< ref "#step-2" >}}).

{{% notice tip %}}
You can use the UI's built-in function documentation by hitting {{% keybinding "alt+enter" %}} while
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
and not "View" since views cannot be used for storage).

{{< figure src="/pages/hello-world/new-repo.png" >}}

### 2.2 Find your Ingest Token

Once you have chosen a repository you need get an access token called an [ingest token]({{< relref "ingest-tokens.md" >}}).
You can find the _default_ ingest token generated for your repository by going to:

`Settings` __→__ `Ingest Tokens` __→__ `Click the Eye Icon`

and copying the default token (or creating a new one).

{{< figure src="/pages/hello-world/ingest-token.png" title="Getting the default ingest token from your repository." >}}


## 3. Choosing a Parser

When data arrives at Humio it needs to be parsed therefore you have to specify
which parser should be used to interpret your data. The parser that you select
is based on the format of your data. One of the most common choices is the 
`kv` (Key-Value) parser. It looks at incoming events and finds `key=value` 
pairs - producing a field `key` with the value `"value"` on the stored event.

You can go to the "Parsers" menu item in the top menu of the UI to explore the parsers
that are available but for now it is a good idea to stick with one of the built-in 
parsers for your first experiments with Humio.


## 4. Sending Data

Having created a repository, copied your ingest token, and selected a parser, you are 
now ready to read one of the following guides on how to ship data to Humio:

- [Configure a data shipper (Rsyslog, FileBeat, Logstash, etc.)]({{< relref "integrations/data-shippers/_index.md" >}}),
- [Use one of our platform integration (Kubernetes, Docker, DC/OS, etc.)]({{< relref "integrations/_index.md" >}}),
- [Or ingest through Humio's REST API]({{< relref "ingest-api.md" >}})

You can read more about these methods in the [sending data to humio]({{< ref "sending-data-to-humio/_index.md" >}}) section.

_Tip: If you are already using ElasticSearch ELK you can also take a look at how easy it is to
[migrate from an Elastic Stack]({{< ref "moving-from-elastic-stack.md" >}}) to Humio._

### 4.1 Extra: Custom Parsers

While Humio has built in support for the most popular logging formats (e.g. AccessLog, JSON),
and can rip out almost anything with the [`kv`]({{< relref "parsers/built-in-parsers/kv.md" >}}). parser, you 
may have special needs for your custom application logs. Fortunately Humio allows you to 
create your own custom parsers as documented here: [create your own custom parser]({{< relref "parsers/creating-a-parser.md" >}}).


## 5. Next Steps

- [Language Syntax]({{< ref "language-syntax/_index.md" >}})
- [Query Function Reference]({{< ref "query-functions/_index.md" >}})
- [Creating Custom Parsers]({{< ref "parsers/_index.md" >}})
- [Using Views]({{< ref "views.md" >}})
- [Controlling Retention]({{< ref "retention.md" >}})

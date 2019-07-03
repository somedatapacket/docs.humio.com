---
title: "Sending Data to Humio"
weight: 200
category_title: "Overview"
---

There are steps to getting your data into Humio:

1. [Generating an Ingest Token]({{< ref "ingest-tokens.md" >}}) Token - A special API token only for the Ingest API.
1. Sending data - Which is the subject of this page
1. Parsing and ingesting data - Described in the [Parsers section]({{< ref "parsers/_index.md" >}})

Sending data to Humio (also called _data shipping_) can be done in a couple of ways:

- Using a [**Data Shipper**]({{< ref "#data-shippers" >}}) ([Filebeat]({{< ref "filebeat.md" >}}), [Logstash]({{< ref "logstash.md" >}}), [Rsyslog]({{< ref "rsyslog.md" >}}), etc.)
- Using a [**Platform Integration**]({{< ref "#platform-integrations" >}}) ([Kubernetes]({{< ref "kubernetes.md" >}}), [Docker]({{< ref "docker.md" >}}), [Mesos]({{< ref "mesos.md" >}}), etc)
- Using the [**Ingest API**]({{< ref "#ingest-api" >}}) directly
- Humio supports the [Elasticsearch Bulk API](https://www.elastic.co/guide/en/elasticsearch/reference/6.x/docs-bulk.html), making integration with many log shippers straight forward.

_In most cases you will want to use a data shipper or one of our platform integrations._

If you are just interested in getting some data into Humio quickly, take a look at
the [getting started: sending application logs]({{< ref "getting-started-application-logs.md" >}}) guide.

Below is an overview of how the respective flows of sending data to Humio work:

{{% notice note %}}
Humio is optimized for live streaming of events in real time. If you
ship data that are *not* live you need to observe some basic rules in order
for the resulting events in Humio be stored as efficiently as if they
had been live. See [Backfilling](#backfilling-guidelines)
{{% /notice  %}}


## Data Shippers {#data-shippers}

A Data Shipper is a small system tool that looks at files and system properties
on a server and send it to Humio. Data shippers take care of buffering, retransmitting
lost messages, log file rolling, network disconnects, and a slew of other things
so your data or logs are send to Humio in a reliable.

**Example Flow**  
In this example "Your Application" is writing logs to a "Log File".
The "Data Shipper" reads the data and pre-processes it (e.g. this could be
converting a multiline stack-trace into a single event).
It then _ships_ the data to Humio on one of our [Ingest APIs]({{< ref "ingest-api.md" >}}).

{{<mermaid align="left">}}
graph LR;
    subgraph Application Server
    A[Your Application] -->|Logging| B(Log File)
    B --> C[Data Shipper]
    C -->|Pre-Processing| C
    end
    C -->|Ingest API| D{Humio}
    D -->|Parser 1| E(Repository 1)
    D -->|Parser 2| F(Repository 2)

    classDef green fill:#5de995;
    class C, green
{{< /mermaid >}}

[List of supported Data Shippers]({{< ref "integrations/data-shippers/_index.md" >}})


## Platform Integrations {#platform-integrations}

If you want to get logs and metrics from your deployment platform, e.g. a Kubernetes cluster or your company PaaS,
you can use one of our [Platform Integrations]({{< ref "sending-data-to-humio/_index.md" >}}).

**Example Flow**  
Depending on your platform the data flow will look slightly different. Some systems
use a built-in logging subsystem, others you start a container running with a data shipper.
Usually you will _assign_ containers/instances in some way to indicate which repository and parser
should be used at ingestion.

{{<mermaid align="left">}}
graph LR;
    subgraph Platform
    C1["Nginx<br/>(assigned: Repo 2/Parser 2)"]   -->|StdOut| B(Platform Logging Sub-System)
    C2["MySQL<br/>(assigned: Repo 2/Parser 3)"]   -->|StdOut| B
    C3["Web App<br/>(assigned: Repo 1/Parser 1)"] -->|StdOut| B
    end
    B -->|Ingest API| D{Humio}
    D -->|Parser 1| E(Repo 1)
    D -->|Parser 2| F(Repo 2)
    D -->|Parser 3| F(Repo 2)


    classDef green fill:#5de995;
    class C, green
{{< /mermaid >}}

Take a look at the individual integrations pages for more details.

## Using the Ingest API {#ingest-api}

[List of API Clients and Framework Integrations]({{< relref "language-integrations/_index.md" >}})

If your needs are simple and you don't care too much about potential data loss due
to e.g. network problem, you can also use Humio's [Ingest API]({{< ref "ingest-api.md" >}}) directly
or through one of Humio's client libraries.

{{<mermaid align="left">}}
graph LR;
    A[Your Application] -->|Ingest API| B(Log File)
{{< /mermaid >}}

As you can see, this is by far the simplest flow, and is completely appropriate
for some scenarios e.g. analytics.

## Sending historial data (Backfilling events) {#backfilling-guidelines}

The other sections were mostly concerned with "live" events that you
want shipped to Humio as soon as it exists.  But perhaps you also have
files with events from the latest month on disk and want them sent to
Humio, along with the "live" events?

There are some rules you should observe for optimal
performance of the resulting data inside Humio and in order for this
to not interfere with the live events already flowing, if any.

* Make sure to ship the historical events in order by their timestamp
  or at least very close to this ordering. A few seconds have little
  consequence whereas hours or days is not good.

* If there are also live events flowing into Humio then make sure the
  historical events get an extra tag to separate them from the live
  events. This makes them a separate stream that does not overlap the live ones.

* If shipping data in parallel (e.g. running multiple filebeat
  instances), then make sure to make those streams visible to Humio by
  using distinct tags for each stream. This makes them visible as separate
  streams that does not overlap the other historical streams.

If those guide lines are not followed the result is likely to be an
increase in the number of segment files and a much higher IO usage
from that when searching time spans that overlap the historical events
or the live events that were ingested while the the backfill was
active. The segment files are likely to get large and overlapping time
spans, leading to a large number of files being searched even when
searching a short time interval.

In short: Don't ship events into one datasource with timestamps (much) out of order.

### Example: Using filebeat to ship historical events

As an example, let's say you have one file of 10 GB of log for each
day in the last month. You want to send all of them in parallel into
Humio, and there is already a stream of live events flowing. In this
case you should run one instance of the desired shipper
(e.g. filebeat) for each file. Each shipper needs a configuration file
that sets a distinct tag. In this example, lets use the filename being
backfilled as the tag value. For filebeat this can be accomplished by
making the `@source` field that is set by filebeat a tag in the parser
in Humio. Or better yet, you can add or extend the `fields` section in
the config:

```
filebeat:
  inputs:
    - paths:
        - /var/log/need-backfilling/myapp.2019-06-17.log
# section that adds the backfill tag:
      fields:
        "@backfill": "2019-06-17"
        "@tags": ["@backfill", "@type"]

queue.mem:
  events: 8000
  flush.min_events: 200
  flush.timeout: 1s

output:
  elasticsearch:
    hosts: ["https://$HUMIO_HOST:443/api/v1/ingest/elastic-bulk"]
    username: $SENDER
    password: $INGEST_TOKEN
    compression_level: 5
    bulk_max_size: 200
    worker: 4

# Don't raise bulk_max_size much: 100 - 300 is the appropriate range.
# While doing so may increase throughput of ingest it has a negative impact on search performance of the resulting events in Humio.
```


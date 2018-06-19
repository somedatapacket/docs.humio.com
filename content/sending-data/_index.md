---
title: "Sending Data"
weight: 200
category_title: "Overview"
---

Sending data to Humio can be done in several ways:

- Using a **Data Shipper** (Filebeat, Logstash, Rsyslog, etc.)
- Using a **Platform Integration**
- Using the **Ingest API** directly

In most cases you will want to use a data shipper or one of our platform integrations.

Below is an overview of how the respective ways of sending data to Humio work:

## Data Shippers

A Data Shipper is a small system tool that looks at files and system properties
on a server and send it to Humio. Data shippers take care of buffering, retransmitting
lost messages, log file rolling, network disconnects, and a slew of other things
so your data or logs are send to Humio in a reliable.

**Example Flow**  
In this example "Your Application" is writing logs to a "Log File".
The "Data Shipper" reads the data and pre-processes it (e.g. this could be converting a multiline stack-trace into a single event).
It then _ships_ the data to Humio on one of our [Ingest APIs]({{< ref "ingest-api.md" >}}).

{{<mermaid align="left">}}
graph LR;
    A[Your Application] -->|Logging| B(Log File)
    B --> C[Data Shipper]
    C -->|Pre-Processing| C
    C -->|Ingest API| D{Humio}
    D -->|Parser 1| E(Repository 1)
    D -->|Parser 2| F(Repository 2)

    classDef green fill:#5de995;
    class C, green
{{< /mermaid >}}

[List of supported Data Shippers]({{< ref "integrations/data-shippers/_index.md" >}})


## Platform Integrations

If you want to get logs and metrics from your deployment platform, e.g. your company PaaS,
you can use one of our Platform Integrations.



## Using the Ingest API

If your needs are simple and you don't care too much about potential data loss due
to e.g. network problem, you can also use Humio's [Ingest API]({{< ref "ingest-api.md" >}}) directly
or through one of Humio's client libraries.


{{<mermaid align="left">}}
graph LR;
    A[Your Application] -->|Logging| B(Log File)
{{< /mermaid >}}


>In this section we will cover everything about how to send your logs to Humio. The section is divided into
[integrations]({{< ref "integrations/_index.md" >}}), which a great starting point if an integration for your platform is
offered, and [data shippers]({{< relref "data-shippers/_index.md" >}}), which should cover all other use cases.

>It's very important you understand how the [parsers]({{< relref "parsers/_index.md" >}}) and
[ingest tokens]({{< relref "ingest_tokens.md" >}}) work.

>Finally, we have a section about how our [Ingest API]({{< relref "ingest-api.md" >}}) works.

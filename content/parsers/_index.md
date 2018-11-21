---
title: "Parsers"
category_title: "Overview"
date: 2018-03-15T08:19:58+01:00
weight: 650
---

When you send logs and metrics to Humio for ingestion it needs to be parsed
before it is stored in a repository. _This is the case for all input channels
except Humio's structured ingest endpoint which stores data as-is._

A parser takes text as input, it can be structured text (like JSON) or unstructured
text (like syslog or application stdout). It then extracts fields which are
stored along with the original text.

<figure>
{{<mermaid align="center">}}
graph LR;
  subgraph External Systems
    Ext1[Filebeat]
    Ext2[Logstash]
    Syslog[Syslog]
    Json1[Web Application]
    Json2[Browser JS Client]
  end

  subgraph Repository A
  Ext1 --> P1("<em>Parser</em><br/><b>accesslog</b>")
  Ext2 --> P1
  Syslog --> P2("<em>Parser</em><br/><b>kv</b>")
  P1 --> S1("Storage")
  P2 --> S1
  end

  subgraph Repository B
  Json1 --> P3("<em>Parser</em><br/><b>custom-parser-1</b>")
  Json2 --> P3
  P3 --> S2("Storage")
  end
{{< /mermaid >}}
<figcaption>Five different clients are sending data to Humio. They each have a parser assigned that will be used during ingestion. E.g. <b>Web Application</b> is using a custom parser while <b>Logstash</b> is using the build-in <em>accesslog</em> parser.</figcaption>
</figure>

## Choosing a parser

A client sending data to Humio must specify which repository to store the data
in and which parser to use for ingesting the data. You do this either by setting
the special `#type` field to the name of the parser to use or by [assigning a
specific parser to the Ingest API Token]({{< ref "parsers/assigning-parsers-to-ingest-tokens.md" >}})
used to authenticate the client. Assigning a parser to the API Token is the recommended
approach since it allows you to change parser in Humio without changing the client.  

### Built-in parsers

Humio supports common log formats via the  [built-in parsers]({{< ref "parsers/built-in-parsers/_index.md" >}}).
They include formats such as `json` and `accesslog` and are suitable when starting out
with Humio. Once you get better acquainted with your data and how parsers work you will likely want to
create your own custom parsers.

### Creating a Custom Parser

Writing a custom parser allows you to take full control of which fields are extracted during ingest and which datasources events are stored in.

Parsers are written in the Humio query language (the same
you use for searching). Here is a guide for [creating a custom parser]({{< ref "creating-a-parser.md" >}}).

---
title: "Rsyslog"
weight: 400
categories: ["Integration", "DataShipper"]
pageImage: /integrations/rsyslog.svg
---

The [Rsyslog](https://www.rsyslog.com) log processor is very popular and is
being shipped with most popular Linux distributions, including Ubuntu and CentOS.
Rsyslog provides [a long list of plugins](https://www.rsyslog.com/plugins/),
most importantly the [Elastic search output plugin](https://www.rsyslog.com/doc/v8-stable/configuration/modules/omelasticsearch.html),
which is supported by Humio.

{{% notice note %}}
On-prem users will have to enable the ElasticSearch bulk endpoint on port 9200. See `ELASTIC_PORT` in
[configuration options]({{< relref "configuration/_index.md#example-configuration-file-with-comments" >}})
{{% /notice %}}

## Minimal configuration
We recommend the following minimal configuration for forwarding all logs to Humio

Create a file named `/etc/rsyslog.d/33-humio.conf` with the following contents

```groovy
module(load="omelasticsearch")
template(name="humiotemplate"
         type="list"
         option.json="on") {
           constant(value="{")
             constant(value="\"@timestamp\":\"")
                property(name="timereported" dateFormat="rfc3339")
                constant(value="\",")
             constant(value="\"message\":\"")
                property(name="msg")
                constant(value="\",")
             constant(value="\"host\":\"")
                property(name="hostname")
                constant(value="\",")
             constant(value="\"severity\":\"")
                property(name="syslogseverity-text")
                constant(value="\",")
             constant(value="\"facility\":\"")
                property(name="syslogfacility-text")
                constant(value="\",")
             constant(value="\"syslogtag\":\"")
                property(name="syslogtag")
                constant(value="\"")
           constant(value="}")
         }
*.* action(type="omelasticsearch"
           server="$HOST"
           template="humiotemplate"
           uid="$INGEST_TOKEN"
           pwd="none"
           bulkmode="on"
           usehttps="on")
```

Remember to replace `$HOST` with your Humio host, i.e. `cloud.humio.com`
and `$INGEST_TOKEN` with an [ingest token]({{< relref "ingest_tokens.md" >}})
for your repository.

Furthermore `bulkmode` and `usehttps` _has_ to be set to `on` for
`cloud.humio.com` and on-prem installations where Humio is serviced
behind a https proxy.

Finally restart rsyslog:

```shell
$ systemctl restart rsyslog.service
```

## Verifying

By now, your logs should start rolling into your repository and can be found with a simple search like

```
syslogtag=*
```

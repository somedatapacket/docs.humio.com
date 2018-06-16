---
title: "Linux"
---

Getting system logs and host metrics from a Linux systems enables you
to monitor a large array of issue.  Here as a small list of some of
the things you could do:

* Find servers that have too much load
* Detect when your are running out of disk space
* See when services reboot or crashes
* See which user run which commands with `sudo`

## Host Metrics

To get the standard host metrics, like cpu usage, load, memory,
etc. use
[Metricbeat](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html).
Metricbeat can extract metrics from many different applications.  For linux host
metrics the system module is of interest.

* [Installation instructions](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-installation.html).

* [System Module](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-module-system.html)

{{% notice note %}}
Metricbeat can provide a lot of metrics (many per process for example).  Experiment with finding the level you need.
{{% /notice %}}

### Example Metricbeat Configuration

```yaml
metricbeat.modules:
  - module: system
    enabled: true
    period: 10s
    metricsets:
      - cpu
      - load
      - filesystem
      - fsstat
      - memory
      - network

output.elasticsearch:
  hosts: ["https://$HOST:443/api/v1/dataspaces/$REPOSITORY_NAME/ingest/elasticsearch"]
  username: $INGEST_TOKEN
```

{{< partial "common-rest-params.html" >}}

See the page on [Metricbeat]({{< relref "sending-data/log_shippers/beats/metricbeat.md" >}}) for more information.

{{% notice note %}}
***Example queries***
check out the these [queries]({{< relref "sending-data/log_shippers/beats/metricbeat.md" >}}) on host metrics
{{% /notice %}}

## System Logs (syslog)

To ship the interesting system logs from `/var/log/` to Humio use
[Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html).

### Example Filebeat Configuration

```yaml
filebeat.prospectors:
- paths:
    - /var/log/syslog
    - /var/log/auth.log
  fields:
    "@type": syslog-utc

output.elasticsearch:
  hosts: ["https://$HOST:443/api/v1/dataspaces/$REPOSITORY_NAME/ingest/elasticsearch"]
  username: $INGEST_TOKEN
```

{{< partial "common-rest-params.html" >}}

Notice the type is `syslog-utc`, which points to the built in syslog parser, expecting the timestamp to be in UTC time.
Often syslog timestamps are in local time. Go ahead and create a new parser with another timezone in Humio if necessary.
You can copy the built in syslog-utc and just change the timezone.
See [Parsing]({{< relref "sending-data/parsers/parsing.md" >}}) for details.


Check out the [Filebeat]({{< relref "sending-data/log_shippers/beats/filebeat.md" >}}) page for more
information.

## Custom Logs or Metrics

If you have custom logs or metrics you want to ship we suggest one of
these strategies:

1. Append the logs/metrics to a log file and use
   [Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
   to ship them similarly to the System logs above.

1. Use cron to run a script that send data to Humio via it
   [Ingest API]({{< relref "sending-data/transport/http_api.md#ingest" >}}).

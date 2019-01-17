---
title: "Docker"
menuTitle: "Docker"
# DON'T ADD CATEGORIES HERE, ANOTHER PAGE ABOUT DOCKER HAS THOSE
slug: docker
pageImage: /integrations/docker.svg
---

In this guide, we assume that you use Docker in the standard way, where logs are captured from `stdout` and `stderr`.

{{% notice tip %}}
Looking for how to run Humio in a Docker container? Try the [Docker installation guide]({{< ref "docker.md" >}}) instead.
{{% /notice %}}

## Container Logs
As of Humio version [1.2.6]({{< ref "/release-notes/_index.md#2019-01-10" >}}) we now have full support for the [Docker Splunk logging driver](https://docs.docker.com/config/containers/logging/splunk/).

Getting logs from a Docker container is as simple as setting the logging driver and adding the `splunk-url` and `splunk-token` logging options to the container, i.e.

```bash
docker run --rm -it \
  --log-driver=splunk \
  --log-opt splunk-url=$BASEURL \
  --log-opt splunk-token=$INGEST_TOKEN \
  alpine ping 8.8.8.8
```

Where:

* `$BASEURL` - is the base URL of your Humio server (e.g. `https://cloud.humio.com` or `http://localhost:8080`)
* `$INGEST_TOKEN` - is the [ingest token]({{< ref "/sending-data-to-humio/ingest-tokens.md" >}}) for your repository, (e.g. a string such as `fS6Kdlb0clqe0UwPcc4slvNFP3Qn1COzG9DEVLw7v0Ii`).

### Parsing the logs

Since Docker just handles log lines from `stdout` as text blobs, you must parse the lines to get the full value from them.

To do this, you can either use a built-in parser, or create new ones for your log types. For more details on creating parsers, see the [parsing page]({{< ref "parsers/_index.md" >}}).

{{% notice tip %}}
In terms of log management, Docker is just a transport layer.<br/><br/>
Before writing a custom parser, see the [built in parsers]({{< ref "parsers/built-in-parsers/_index.md" >}}) page to see if Humio already supports your log type.
{{% /notice %}}

### Configuring Docker daemon

To configure the Docker daemon to forward all logs for all containers by default you'll have to update the [`daemon.json` configuration file](https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file) with the following parameters

```json
{
  "log-driver" : "splunk",
  "log-opts" : {
    "splunk-token" : "$INGEST_TOKEN",
    "splunk-url" : "$BASEURL"
  }
}
```

Don't forget to restart Docker daemon.

To excluding from log forwarding you can run your container with the default `json-file` logging driver, i.e.
```bash
docker run --log-driver=json-file --rm alpine whoami
```

## Notes on blocking behaviour

By default Docker logging drivers are blocking, meaning that it will prevent the process from printing to `stdout` and `stderr` while logs are being handled. This can, and should be, controlled by the [`mode` log-opt](https://docs.docker.com/config/containers/logging/configure/#configure-the-delivery-mode-of-log-messages-from-container-to-log-driver).

In addition to the mode, the Splunk logging driver has it's own [buffer](https://docs.docker.com/config/containers/logging/splunk/#advanced-options), which will postpone the process pausing somewhat.

Finally it should be noted that Docker will throw away the oldest logs in `non-blocking` mode when the buffer runs full. 

## Docker daemon Metrics

To get standard host level metrics for your docker containers, use [Metricbeat](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html).
It includes a [docker module](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-module-docker.html).

### Example Metricbeat Configuration

``` yaml
metricbeat.modules:
  - module: docker
    metricsets: ["cpu", "info", "memory", "network", "diskio", "container"]
    hosts: ["unix:///var/run/docker.sock"]
    enabled: true
    period: 10s

output.elasticsearch:
  hosts: ["$BASEURL/api/v1/ingest/elastic-bulk"]
  username: $INGEST_TOKEN
```

{{< partial "common-rest-params.html" >}}

See also the page on [Beats]({{< relref "sending_data/data-shippers/beats/_index.md" >}}) for more information.

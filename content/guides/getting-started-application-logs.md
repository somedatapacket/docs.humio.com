---
title: "Getting Started: Application Logs"
---

So you are developing your own application and want to send its logs
to Humio?

In this guide we will use [Filebeat]({{< relref "filebeat.md" >}}) to send
application logs from your application's log file.

Refer to [Elastic's Filebeat documentation](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html) for setting up Filebeat on your system.

{{% notice note %}}
If you are using __Docker__ to run your application, it might be better to start by looking at the see the
[Docker Container documentation]({{< relref "docker.md" >}}).
{{% /notice %}}


## Filebeat Configuration

Filebeat sends logs as unstructured text. To parse these logs once they arrive at Humio you need
to assign a parser. You do this by configuring Filebeat to add an additional field called `@type`.
You set `@type` to the name of one of Humio's built-in parsers or one of your own parsers.

For now let os assume we can use the build-in [`kv`]({{< ref "kv.md" >}}) (Key-Value) parser, it extracts fields
from the log lines, anything of the form `key=value`.
See [Parsing Logs]({{< relref "parsers/_index.md" >}}) for more information on parsing log data.

Example Filebeat configuration with a custom log type:

```yaml
filebeat.prospectors:
- paths:
    - $PATH_TO_YOUR_APPLICATION_LOG
  fields:
    "@type": $PARSER_NAME

output.elasticsearch:
  hosts: ["https://$HOST:443/api/v1/dataspaces/$REPOSITORY_NAME/ingest/elasticsearch"]
  username: $INGEST_TOKEN
```

* `$HOST` - address/hostname of your Humio server (e.g. `cloud.humio.com`)
* `$REPOSITORY_NAME` - name of your repository on your server (e.g. `sandbox`)
* `$INGEST_TOKEN` - [ingest token]({{< relref "ingest-tokens.md" >}}) for your repository, (e.g. a string such as `fS6Kdlb0clqe0UwPcc4slvNFP3Qn1COzG9DEVLw7v0Ii`).
* `PATH_TO_YOUR_APPLICATION_LOG` - the file path to the log file you want to send.
* `PARSER_NAME` - the name of either one of the built-in parsers such as `kv` (Key-Value) or a [custom parser]({{< relref "parsers/_index.md" >}}).

See the detailed documentation for [filebeat]({{< relref "filebeat.md" >}})

{{% notice tip %}}
Remember to set a limit on the size of the log file, and rotate it so that
you don't run out of disk space.
{{% /notice %}}

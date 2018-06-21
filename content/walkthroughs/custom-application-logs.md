---
title: "Custom Application Logs"
---

So you are developing your own application and want to ship its logs
to Humio?

The easiest way to ship your application logs is to have your application
write logs to a file on disk, and then use
[Filebeat]({{< relref "sending_logs_to_humio/log_shippers/beats/filebeat.md" >}}) to ship them to Humio.

{{% notice tip %}}
Remember to set a limit on the size of the log file, and rotate it so that
you don't run out of disk space.
{{% /notice %}}

{{% notice note %}}
If you are using __Docker__ for your application, see the
[Docker Containers documentation]({{< relref "sending_logs_to_humio/integrations/docker.md" >}})
{{% /notice %}}


## Filebeat Configuration

Filebeat ship logs as unstructured text. To parse these logs, you need
to set a log type using the `@type` field.  Humio will use the parser specified by `@type` to parse the data.
See [Parsing Logs]({{< relref "sending_logs_to_humio/parsers/parsing.md" >}}) for more information on parsing log data.

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
* `$INGEST_TOKEN` - [ingest token]({{ relref "sending_logs_to_humio/ingest_tokens" }}) for your repository, (e.g. a string such as `fS6Kdlb0clqe0UwPcc4slvNFP3Qn1COzG9DEVLw7v0Ii`).
* `PATH_TO_YOUR_APPLICATION_LOG` - the file path to the log file you want to send.
* `PARSER_NAME` - the name of either one of the built-in parsers such as `kv` (Key-Value) or a [custom parser]({{< relref "sending_logs_to_humio/parsers/parsing.md" >}}).

See the detailed documentation for [filebeat]({{ relref "sending_logs_to_humio/log_shippers/beats/filebeat.md" }})

---
title: "Others"
---

So you are developing your own application and want to ship its logs
to Humio?  The easiest is to just log to a file on disk (remember to
set a limit on its size and rotate it so you don't run out of disk
space) and then use [Filebeat](/sending-data/log_shippers/beats/) to ship it
to Humio.

{{% notice note %}}
If you are using Docker for your own application, go to the [Docker Containers documentation]({{ relref "docker.md" }})
{{% /notice %}}


## Filebeat Configuration

Filebeat ship logs as unstructured text. To parse these logs, you need
to set a log type using the `@type` field.  Humio will use the parser specified by `@type` to parse the data.  
See [Parsing Logs](/sending-data/parsers/parsing/) for more information on parsing log data.

Example Filebeat configuration with a custom log type:

```yaml
filebeat.prospectors:
- paths:
    - $PATH_TO_APPLICATION_LOG
  fields:
    "@type": $PARSER_NAME

output.elasticsearch:
  hosts: ["https://$HOST:443/api/v1/dataspaces/$REPOSITORY_NAME/ingest/elasticsearch"]
  username: $INGEST_TOKEN
```

See the detailed [documentation for Filebeat]({{< relref "filebeat.md" >}})

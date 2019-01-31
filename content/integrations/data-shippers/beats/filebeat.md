---
title: "Filebeat"
categories: ["Integration", "DataShipper"]
categories_weight: -100
pageImage: /integrations/filebeat.svg
aliases: ["/sending-data/data-shippers/beats/filebeat/"]
---

[Filebeat](https://www.elastic.co/products/beats/filebeat) is a lightweight,
open source program that can monitor log files and send data to servers like Humio.

Filebeat has some properties that make it a great tool for sending file data to Humio:

* **It uses few resources.**

    This is important because the Filebeat agent must run on each server that you want to capture data from.

* **It is easy to install and run.**

    Filebeat is written in the Go programming language, and is built into one binary.

* **It handles network problems gracefully.**

    When Filebeat reads a file, it keeps track of the last point that it has read to.
    If there is no network connection, then Filebeat waits to retry data transmission.
    It continues data transmission when the connection is working again.


{{% notice note %}}
***Official documentation***  
Check out Filebeat's [official documentation](https://www.elastic.co/guide/en/beats/filebeat/current/index.html).
{{% /notice %}}

## Installation

To download Filebeat, visit the [Filebeat downloads page](https://www.elastic.co/downloads/beats/filebeat)

{{% notice note %}}
***Installation documentation***  
You can find installation documentation for Filebeat at [the Filebeat Installation page of the official Filebeat website](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html).
{{% /notice %}}

## Configuration

Humio supports parts of the ElasticSearch bulk ingest API.
Data can be sent to Humio by configuring Filebeat to use the built in Elastic Search output.

{{% notice note %}}
***Configuration documentation***

You can find configuration documentation for Filebeat at [the Filebeat configuration page of the official Filebeat website](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-configuration-details.html).
{{% /notice %}}

The following example shows a simple Filebeat configuration that sends data to Humio:

``` yaml
filebeat.inputs:
- paths:
    - $PATH_TO_LOG_FILE
  encoding: utf-8
  fields:
    aField: value

queue.mem:
  events: 8000
  flush.min_events: 1000
  flush.timeout: 1s

output:
  elasticsearch:
    hosts: ["$BASEURL/api/v1/ingest/elastic-bulk"]
    username: anything
    password: $INGEST_TOKEN
    compression_level: 5
    bulk_max_size: 200
    worker: 1

```

{{% notice note %}}
The Filebeat configuration file is located at `/etc/filebeat/filebeat.yml` on Linux.
{{% /notice %}}

You must make the following changes to the sample configuration:

* Insert a `path` section for each log file you want to monitor in `$PATH_TO_LOG_FILE`.
  It is possible to insert a input configuration (with `paths` and `fields` etc) for each file that filebeat should monitor

* Add other fields in the fields section. These fields, and their values, will be added to each event.

* Insert the URL containing the Humio host in the `$BASEURL` field in the ElasticSearch output. For example `https://cloud.humio.com:443`
  Note that the URL specifies the repository that Humio sends events to.
  In the example, the URL points to Humio in the cloud, which is fine if you are using our hosted service.  
  It is important to specify the port number in the URL otherwise Filebeat defaults to using 9200.
* Insert an [ingest token]({{< relref "ingest-tokens.md" >}}) from the repository as the password. Set the username to anything - it will get logged in the access log of any proxy on the path so using e.g. the hostname of the sender is a good option.

* Specify the text encoding to use when reading files using the `encoding` field.
  If the log files use special, non-ASCII characters, then set the encoding here. For example, `utf-8` or `latin1`.

* If all your events are fairly small, you can increase `bulk_max_size` from the default of 200. The default of 200 is fine for most use cases.
  The Humio server does not limit the size of the ingest request.
  But keep bulk_max_size low, as you may get the requests timed out if they get too large. In case of timeouts filebeat will back off, thus getting worse performance then with a lower bulk_max_size.
  (Note! The Humio cloud on cloud.humio.com does limit requests to 32 MB. If you go above this limit, you will get "Failed to perform any bulk index operations: 413 Request Entity Too Large"
  if a request ends up being too large, measured in bytes, not in number of events. If this happens, lower bulk_max_size as filebeat will otherwise keep retrying that request and not move on to other events.)

* You may want to increase the number of worker instances (`worker`) from the default of 1 to (say) 5 or 10 to achieve more throughput if filebeat is not able to keep up with the inputs. If increasing bulk_max_size is possible then do that too.

An important next step is [choosing a parser for your filebeat events]({{< relref "filebeat.md#parsing-data" >}}).

## Running Filebeat {#running-filebeat}

Run Filebeat as a service on Linux with the following commands

``` shell
sudo systemctl enable filebeat
sudo systemctl restart filebeat
```

{{% notice note %}}

### Testing Filebeat

On linux Filebeat is often placed at `/usr/share/filebeat/bin/filebeat`
To test it can be run like `/usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat.yml`
{{% /notice %}}

## Parsing data {#parsing-data}

Humio uses parsers to parse the data from Filebeat into events.
Parsers can extract fields from the input data thereby adding structure to the log events.
For more information on parsers, see [parsing]({{< relref "parsers/_index.md" >}}).

{{% notice note %}}
Take a look at Humio's [built-in parsers]({{< ref "parsers/built-in-parsers/_index.md" >}}).
{{% /notice %}}

The recommended way of choosing a parser is by [assigning a specific parser to the Ingest API Token]({{< ref "assigning-parsers-to-ingest-tokens.md" >}})
used to authenticate the client. This allows you to change parser in Humio without changing the client. Alternatively you can specify the parser/type for each monitored file using the `type` field in the fields section in the Filebeat configuration. E.g:

``` yaml
filebeat.inputs:
- paths:
    - $PATH_TO_LOG_FILE`
  encoding: utf-8
  fields:
    "type": $TYPE
```

If no parser is specified Humio's built in key value parser (`kv`) will be used.
The key value parser expects the incoming string to start with a timestamp formatted in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601).
It will also look for key value pairs in the string on the form `a=b`.


### Parsing JSON data

We DO NOT recommend that you use the JSON parsing built into Filebeat. Instead Humio has it's own JSON support.
Filebeat processes logs line by line, so JSON parsing will only work if there is one JSON object per line.
By using the [built-in json parser]({{< ref "json.md" >}}) you can get JSON fields extracted during ingest.
You can also [create a custom JSON parser]({{< ref "creating-a-parser.md" >}}) to get more control over the fields that are created.


## Adding fields
It's possible to add fields with static values using the fields section. These fields will be added to each event.

### Default fields

Filebeat automatically sends the host (`beat.hostname`) and filename (`source`) along with the data. Humio adds these fields to each event.
The fields are added as `@host` and `@source` in order to not collide with other fields in the event.

{{% notice tip %}}
To avoid having the `@host` and `@source` fields specify `@host` and `@source` in the `fields` section with an empty value.
{{% /notice %}}

## Tags

Humio saves data in Data Sources. You can provide a set of Tags to specify which Data Source the data is saved in.  
See [the section on tags]({{< ref "tagging.md" >}}) for more information about tags and Data Sources.  
If a `type` is configured in Filebeat it's always used as tag. Other fields can be used
as tags as well by defining the fields as `tagFields` in the
[parser]({{< relref "parsers/_index.md" >}}) pointed to by the `type`.  
In Humio tags always start with a #. When turning a field into a tag it will
be prepended with `#`.


## Multiline events

By default, Filebeat creates one event for each line in the in a file. However, you can also split events in different ways.
For example, stack traces in many programming languages span multiple lines.

You can specify multiline settings in the Filebeat configuration.

{{% notice note %}}
***Multiline documentation***

[See Filebeat's official multiline configuration documentation](https://www.elastic.co/guide/en/beats/filebeat/master/multiline-examples.html)
{{% /notice %}}

Often a log event starts with a timestamp and we want to read all lines until we see a new line starting with a timestamp.
In Filebeat that can be done like this:

```yaml
multiline.pattern: '^[0-9]{4}-[0-9]{2}-[0-9]{2}'
multiline.negate: true
multiline.match: after
```

The `multiline.pattern` should match your timestamp format

## Full configuration example

``` yaml
filebeat:
  inputs:
    - paths:
        - /var/log/nginx/access.log
      fields:
        aField: value
    - paths:
        - humio_std_out.log
      fields:
        service: humio
      multiline:
        pattern: '^[0-9]{4}-[0-9]{2}-[0-9]{2}'
        negate: true
        match: after

queue.mem:
  events: 8000
  flush.min_events: 1000
  flush.timeout: 1s

output:
  elasticsearch:
    hosts: ["https://cloud.humio.com:443/api/v1/ingest/elastic-bulk"]
    username: from-me
    password: "some-ingest-token"
    compression_level: 5
    bulk_max_size: 200
    worker: 1

logging:
  level: info
  to_files: true
  to_syslog: false
  files:
    path: /var/log/filebeat
    name: filebeat.log
    keepfiles: 3

```
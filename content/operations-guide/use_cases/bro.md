---
title: "Zeek  (formerly known as Bro)"
menuTitle: Zeek/Bro Network Security Monitor
aliases: ["/guides/bro"]
---

Humio is an excellent tool for analyzing [Zeek](https://zeek.org) data.  
This document describes how to get Zeek data into Humio

{{% notice note %}}
Pre cooked dashboards for Zeek data can be found [further down this page](#dashboards)
{{% /notice %}}

## Configure Zeek

First let us setup Zeek to write logs in the JSON format. That will make it easier to send them to Humio.

[Seth](https://twitter.com/remor) from [Corelight](https://www.corelight.com/)
has made a nice Zeek script to support streaming Zeek logs as JSON.

The script requires Zeek/Bro 2.5.2+

[Download it here](/zeek-files/corelight-logs.bro)

One way to install the script is to put it in the `<bro-directory>/site/` folder
and then add the Bro script to the end of `local.bro` like this:

```
@load corelight-logs.bro
```

The script will add new JSON log files in the Bro log directory next to the standard CSV log files.
The new JSON files will be prepended with `corelight_` and otherwise have the same name as its corresponding CSV file.
So there will be a `corelight_conn.log` log file corresponding to the `conn.log` CSV log file etc.  

By default each JSON log file is rotated every 15 minutes, and 4 versions of the file is kept.
These files will be monitored by Filebeat and data send to Humio as is described
below in the section [Configure Filebeat]({{< relref "#configure-filebeat" >}})

Some available configurations options for the Zeek script are:

```
redef CorelightLogs::disable_default_logs = F;      ## Disable default logs and only log in JSON
redef CorelightLogs::extra_files = 4;               ## number of files to keep when rotating
redef CorelightLogs::rotation_interval = 15mins;    ## time before rotating a file
```

These options can be appended to `local.bro`


It is also possible to test the script by running:  
```shell
bro -i eth0 <bro-directory-full-path>/site/json-logs-by-corelight.bro
```

{{% notice note %}}
On Mac the default network interface is `en0`
{{% /notice %}}

You can follow the above or add the Zeek script in a way matching your installation.
With the script in place, and after a restart, Zeek should be logging in JSON format,
formatted as JSON objects separated by newlines.
Verify this by looking in one of the log files, for example `corelight_conn.log`.

## Configure Humio {#configure-humio}

We assume you already have a local Humio running or is using Humio as a Service.
Head over to the [installation docs]({{< relref "installation/_index.md" >}})
for instructions on how to install Humio.

If you don't have a [repository]({{< relref "repositories.md" >}}),
create one by clicking 'Add Repository' on the front page of Humio.


## Configure Filebeat {#configure-filebeat}

We will use [Filebeat]({{< relref "filebeat.md" >}}) to ship Zeek logs to Humio.
Filebeat is a light weight, open source agent that can monitor log files and send data to servers like Humio.
Filebeat must be installed on the server having the Zeek logs.
Follow the instructions [here]({{< relref "filebeat.md#installation" >}}) to download and install Filebeat.
Then return here to configure Filebeat.

Below is a filebeat.yml configuration file for sending Zeek logs to Humio:

```yaml
filebeat.inputs:
- paths:
    - "${ZEEK_LOG_DIR}/corelight_*.log" #The file path should be a glob matching the json log files
  fields:
    type: bro-json

queue.mem:
  events: 6000
  flush.min_events: 1000 
  flush.timeout: 1s

#-------------------------- ElasticSearch output ------------------------------
output.elasticsearch:
  hosts: ["http://${HOST}:8080/api/v1/ingest/elastic-bulk"]
  password: "${INGEST_TOKEN}"
  compression_level: 5
  bulk_max_size: 1000
  worker: 3

#================================ Logging =====================================
# Sets log level. The default log level is info.
# Available log levels are: critical, error, warning, info, debug
logging.level: info

logging.selectors: ["*"]

```

The configuration file has these parameters:

* `$ZEEK_LOG_DIR`  
* `$HOST`  
* `$INGEST_TOKEN`  

You can replace the parameters in the file or set them as ENV parameters when starting Filebeat.  
You can [create an ingest token following the instructions here]({{< ref "ingest-tokens.md" >}}).

Note that in the filebeat configuration we specify that Humio should use the built-in parser `bro-json` to parse the data with:

```yaml
  fields:
    type: bro-json
```

As Zeek often generates a lot of data we have configured Filebeat to use 3 `workers`, a `bulk_max_size` of 1000 and then configured the in memory queue `queue.mem` accordingly. Experiment with increasing this if filebeat cannot keep up with sending data.


### Run Filebeat

With the config in place we are ready to run Filebeat.

Run Filebeat as described [here]({{< relref "filebeat.md#running-filebeat" >}}).  
An example of running Filebeat with the above parameters as environment variables:  

```shell
ZEEK_LOG_DIR=/home/bro/logs HOST=localhost INGEST_TOKEN=******************** /usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat.yml
```

{{% notice note %}}
***Logging is verbose***  
Logging is set to debug in the above Filebeat configuration. It can be a good idea to set it to info when things are running well.
Filebeat log files are by default rotated and only 7 files of 10 megabytes each are kept, so it should not fill up the disk. See more in the [docs](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-logging.html)
{{% /notice %}}


If there is data in the Zeek log files, Filebeat will start shipping the data to Humio.
Go to the zeek repository in Humio and data should be streaming in. Filebeat starts shipping data from the start of the file.
If data is old, widen the default search interval in Humio.
To see data flowing into Humio in realtime, select a time interval of "1m window". This will "tail" the data as it arrives in Humio.


## Search Zeek Data

With everything in place, Zeek data is streaming into Humio.  

In the above Filebeat configuration events are given a `#path` tag describing
from which file they originate. To search for data from the `http.log`:

```humio
#path=http
```

Or search data from the `conn.log`

```humio
#path=conn
```

Just leave out the `#path` filter to search across all files. For example we
could count how many events we have in the different files:

```humio
groupBy(#path, function=count())
```

Or show the event distribution over time

```humio
timechart(#path, unit="1/minute")
```

If you are new to Humio and its search capabilities, try the [online tutorial]({{< ref "tutorial/_index.md">}}).  
There is a link to the tutorial in the top right corner of the Humio UI.


## Zeek Dashboards {#dashboards}

Corelight has created some nice [Zeek dashboards](/zeek-files/corelight-dashboards.zip).    
The dashboards can be added to Humio by extracting the zip file. Then go to dashboards in your selected Humio repository and press the "Add Dashboard" button. Select template file and add the extracted dashboard JSON files.

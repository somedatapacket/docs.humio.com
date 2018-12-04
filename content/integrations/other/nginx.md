---
title: "Nginx"
categories: ["Integration", "OtherIntegration"]
pageImage: /integrations/nginx.svg
---

You can integrate the Nginx web server with Humio. This lets you follow what
is happening in Nginx in great detail. For example, you can:

* Find slow pages (high response time)

* Discover dead links and other issues with your site

* Monitor for internal server errors

* See when Nginx is nearing its load limit


## Logs

To ship the Nginx access logs to Humio, use
[Filebeat]({{< ref "filebeat.md" >}}).

{{% notice note %}}
On Linux, the access log is in `/var/log/nginx/access.log`
{{% /notice %}}

### Example Filebeat Configuration

``` yaml
filebeat.inputs:
- paths:
    - /var/log/nginx/access.log
  fields:
    "@type": accesslog

output.elasticsearch:
  hosts: ["https://$BASEURL/api/v1/ingest/elastic-bulk"]
  username: $INGEST_TOKEN
```

{{< partial "common-rest-params.html" >}}

See the page on [Filebeat](/sending-data/data-shippers/beats/filebeat/) for further details.

The above Filebeat configuration uses the [built-in parser `accesslog`](/sending-data/parsers/built_in_parsers/#accesslog).
The parser can parse logs formatted in the default Nginx log configuration.
If your log Nginx configuration is modified, create a [custom parser]({{< relref "parsers/_index.md" >}}), by copying the accesslog parser and modifying it.
Then [connect the parser to the ingest token]({{< ref "assigning-parsers-to-ingest-tokens.md" >}}) or put its name as the value of the @type field in the Filebeat configuration.

{{% notice note %}}
***Response time***  
By default Nginx does not include response time in the log.
Response time can be added by editing the nginx logging configuration (nginx.conf).
Add the field `$request_time` to the log_format.
Read more about logging responsetime and other performance metrics [here](https://www.nginx.com/blog/using-nginx-logging-for-application-performance-monitoring/)
{{% /notice %}}


### Example queries on Nginx logs

* Count the different status codes:
 > `#type=accesslog | groupby(statuscode) | sort()`

![Screenshot](/images/nginx-statuscodes.png)

* Show the distribution of error statuscodes over time
 > `#type=accesslog statuscode >= 400 | timechart(statuscode)`

![Screenshot](/images/nginx-statuscodes-timechart.png)

* Show responsetime percentiles.
 > `#type=accesslog | timechart(function=percentile(responsetime, percentiles=[50, 75, 90, 99, 100]))`

{{% notice note %}}
Unfortunately responsetime for each request is not part of the default Nginx logging.
See the tip above on how to add it.
{{% /notice %}}

![Screenshot](/images/nginx-responsetime-percentiles.png)


* Show top 5 referring web sites

   `#type=accesslog | regex("https?://(?<domain>[^:/]+)", field=referrer) | groupBy(domain) | sort(limit=10)`

{{% notice note %}}
***Field extraction at search time.***  
The {{% function "regex" %}} function extracts a new field `domain` and captures the domain part of the referrer URL.
The field is then used later in the query pipeline.
{{% /notice %}}

![Screenshot](/images/nginx-referrer.png)


## Metrics

To get connection-related metrics from Nginx, use
[Metricbeat](https://www.elastic.co/guide/en/beats/metricbeat/current/index.html).
It includes an [Nginx module](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-module-nginx.html)
that uses the
[`http_stub_status_module`](http://nginx.org/en/docs/http/ngx_http_stub_status_module.html)
module in Nginx to collect metrics.

{{% notice note %}}
You can check if the `http_stub_status_module` module is enabled by running
this command:

```
$ nginx -V 2>&1 | grep -o
with-http_stub_status_module
```

If the command produces output, then the module is enabled.
{{% /notice %}}

Ensure that the `http_stub_status_module` module is exposed by adding the following
configuration to Nginx:

```nginx
server {
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
```

This ensures that the `http_stub_status_module` module is only accessible from localhost.


### Example Metricbeat Configuration

``` yaml
metricbeat.modules:
  - module: nginx
    metricsets: ["stubstatus"]
    enabled: true
    period: 10s
    hosts: ["http://127.0.0.1/nginx_status"] # Nginx hosts

  - module: system
    enabled: true
    period: 10s
    metricsets: ["process"]
    processes: ['.*nginx.*']

output.elasticsearch:
  hosts: ["https://$BASEURL/api/v1/ingest/elastic-bulk"]
  username: $INGEST_TOKEN
```

{{< partial "common-rest-params.html" >}}

See also the page on [Metricbeat](/sending-data/data-shippers/beats/metricbeat/) for more
information.

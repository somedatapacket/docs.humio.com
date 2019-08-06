---
title: Caddy reverse proxy
aliases: ["/configuration/reverse-proxy/caddy-reverse-proxy"]
---

[Caddy](https://caddyserver.com) is a very powerful HTTP/2 web server with automatic HTTPS.

If you are not yet familiar with Caddy we strongly recommend reading through their [tutorials](https://caddyserver.com/tutorial).

For the most basic setup with a single node Humio cluster all that's needed a basic [`proxy`](https://caddyserver.com/docs/proxy), although we do recommend adding a [log](https://caddyserver.com/docs/log) as well

```
log / /var/log/humio-access.log "{combined}"
proxy / http://127.0.0.1:8080 {
  health_check /api/v1/status
  transparent
  websocket
}
```

Save it as `/etc/caddy/Caddyfile` and start caddy with `caddy -host=humio.example.com -agree=true -conf=/etc/caddy/Caddyfile -email=${YOUR_EMAIL}`

# Example for a cluster with multiple hosts

```
humio.example.com {
  log / /var/log/caddy/humio.http.log "{combined}"
  proxy /api/v1/ingest humio01:8080 humio02:8080 humio03:8080 {
    policy least_conn
    health_check /api/v1/status
    transparent
  }
  proxy / humio01:8080 humio02:8080 humio03:8080 {
    policy header Humio-Query-Session
    health_check /api/v1/status
    transparent
    websocket
  }
}
https://humio.example.com:9200 {
  log / /var/log/caddy/humio.es.log "{combined}"
  proxy / humio01:9200 humio02:9200 humio03:9200 {
    policy least_conn
    transparent
  }
}
```

# Forwarding and parsing access logs to Humio

Although there are a few other options for forwarding logs through [syslog](https://caddyserver.com/docs/log#destination), we recommend running [Filebeat]({{< ref "filebeat.md" >}}) alongside Caddy. 

The minimal Filebeat configuration would look something like this

```yaml
filebeat.inputs:
- paths:
    - "/var/log/caddy*.log"
  encoding: utf-8

output:
  elasticsearch:
    hosts: ["$BASEURL/api/v1/ingest/elastic-bulk"]
    username: $INGEST_TOKEN
    compression_level: 5
    bulk_max_size: 200
    worker: 1
```

The `{combined}` format expands to the following format

```
{remote} - {user} [{when}] \"{method} {uri} {proto}\" {status} {size} \"{>Referer}\" \"{>User-Agent}\"
```

Which can be parsed with the following [Humio parser]({{< ref "creating-a-parser.md" >}})

```
/^(?<remote>\S+) - (?<user>\S+?) \[(?<when>\S+\s\S+)\] "(?<method>\S+?) (?<uri>\S+) (?<proto>\S+)" (?<status>\d+) (?<size>\d+) "(?<referrer>.*?)" "(?<useragent>.+?)"/
| @timestamp := parseTimestamp("dd/MMM/yyyy:HH:mm:ss Z", field=when, timezone="Europe/Berlin")
```

Make sure to [link your ingest token]({{< ref "assigning-parsers-to-ingest-tokens.md" >}}) to the above parser.

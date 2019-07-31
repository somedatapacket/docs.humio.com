---
title: Reverse Proxy Setup
aliases: ["/configuration/reverse-proxy"]
---

It is possible to put Humio behind a proxy server. It is a good idea to keep the connection from the browser "sticky"
towards the same Humio node in the cluster. Humios UI sets a header `Humio-Query-Session` which should be used to select a node in the Humio cluster.


### Sharing query results across users

If two or more users or dashboards execute the same query then Humio
can make them all share the same search internally, provided the same
Humio node in the cluster is being used as the http endpoint from
those browsers. This is achieved by using the `Humio-Query-Session` header to route requests to Humio servers.
The UI will make sure the value of the `Humio-Query-Session` header is the same for identical queries.

{{% notice warning %}}
It is important that the proxy does not rewrite urls, when forwarding to Humio.
{{% /notice %}}

## Example configurations

{{% children sort="name"  %}}

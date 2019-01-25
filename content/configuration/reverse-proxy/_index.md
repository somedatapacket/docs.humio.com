---
title: Reverse Proxy Setup
---

It is possible to put Humio behind a proxy server. You can use any
reverse proxy you want, as long as it can keep the connection from the
browser to Humio "Sticky" towards the same Humio node, at least as
long as that node is alive if you have multiple Humio nodes in a
clustered setup.

### Sharing query results across users

If two or more users or dashboards execute the same query then Humio
can make them all share the same search internally, provided the same
Humio node in the cluster is being used as the http endpoint from
those browsers. To help achieve this the humio UI adds a header named
`Humio-Query-Session` to search requests that one can use as the input
to select the desired backend server in your load balancer. Only
searches have this header, as all other requests can ask any of the
Humio backends in the cluster. (The header was added in Humio version
1.2.10.)

{{% notice warning %}}
It is important that the proxy does not rewrite urls, when forwarding to Humio.
{{% /notice %}}

## Example configurations

{{% children sort="name"  %}}

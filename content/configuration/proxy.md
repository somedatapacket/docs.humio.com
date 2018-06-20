---
title: Proxy Setup
---

It is possible to put Humio behind a proxy server.

{{% notice warning %}}
It is important that the proxy does not rewrite urls, when forwarding to Humio.
{{% /notice %}}

For example a proxy server could accept all request at `http://example.com`
and expose humio on `http://example.com/internal/humio/`.

For this to work, the proxy must be set up to forward incoming requests with a
location starting with `/internal/humio` to the Humio server and
Humio must be configured with a proxy prefix url `/internal/humio`. This is done
by letting the proxy add the header `X-Forwarded-Prefix`.

Humio requires the proxy to add the header `X-Forwarded-Prefix` only when Humio
is hosted at at a non-empty prefix.
Thus hosting Humio at "http://humio.example.com/" works without adding a header.
An example configuration snippet for an nginx location is:

```nginx
location /internal/humio {

    proxy_set_header        X-Forwarded-Prefix /internal/humio;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        Host $host;

    proxy_pass          http://localhost:8080;
    proxy_read_timeout  10;
    proxy_redirect http:// https://;
    expires off;
    proxy_http_version 1.1;
  }
```

If it is not feasible for you to add the header `X-Forwarded-Prefix` in your proxy,
there is a fall-back solution: You can set `PROXY_PREFIX_URL` in
your `/home/humio/humio-config.env`.

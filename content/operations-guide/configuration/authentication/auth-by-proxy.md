---
title: Authenticating with a Proxy
menuTitle: Proxy
aliases: ["/configuration/authentication/auth-by-proxy"]
---

Make Humio use the username provided by a HTTP proxy.

If you have a "reverse proxy" in front of Humio, and that proxy has a way of knowing a proper username or user email or
other unique user identifier, you can let the proxy decide what username the user gets access as inside Humio.
This is one way to accomplish single sign-on in certain configurations.

{{% notice note %}}
Make sure Humio is not accessible without passing through the proxy, as direct access to the Humio server
in this configuration allows anyone to assume any identity in Humio.
{{% /notice %}}

Configure using:

```shell
AUTHENTICATION_METHOD=byproxy
AUTH_BY_PROXY_HEADER_NAME=name-of-http-header
```

The proxy must add a header with the username of the end user in the specified header.
If the proxy leaves the header blank, the user does not get authenticated,
and can thus only access e.g. shared dashboards

Please note, that Humio uses the "Authentication" header as transport from the browser to the Humio backend in this case too.
It is thus not possible to use a proxy that also uses this header. This rules out using e.g. https://github.com/bitly/oauth2_proxy

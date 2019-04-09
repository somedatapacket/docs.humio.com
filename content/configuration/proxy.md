---
title: Proxy Setup
---

It is possible to configure Humio to access the internet through a proxy server.

At the moment this is possible for sending alert notifications and S3 archiving.  
To setup a proxy use the following configuration properties:

``` shell
HTTP_PROXY_HOST=proxy.myorganisation.com
HTTP_PROXY_PORT=3129
HTTP_PROXY_USERNAME=you
HTTP_PROXY_PASSWORD=your-secret-password
```

username and password can be left out if they are not required
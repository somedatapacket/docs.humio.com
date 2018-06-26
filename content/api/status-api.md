---
title: Status API
---

## Status

Humio has a status endpoint for monitoring if Humio is up and running. The endpoint can be called without authentication.

```
GET /api/v1/status
```

The endpoint will return HTTP status code 200 if Humio is running. The response contains JSON looking like this:

``` json
{"status":"ok","version":"1.1.2--build-3034--sha-24ed501fe"}
```
The response contains the running version of Humio. The version can be handy when automating deployment to check that the new version is actually running. 
The version is also available for humans in the UI, at the bottom on the frontpage. 

This example uses curl to call the status endpoint:
```shell
curl http://humio-host:8080/api/v1/status
```
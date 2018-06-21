---
title: accesslog
---

This parser can handle the `accesslog` format. This format is the default log format used by Apache and Nginx.  
The parser also supports putting the response time at the end of the log line.  
If you have modified the logging of your web server, then copy the built-in accesslog parser and modify it to suit your customizations.

## Example Input

```
localhost - - [25/Feb/2017:21:05:16 +0100] "POST /api/v1/dataspaces/myrepo/ingest/elasticsearch/_bulk HTTP/1.1" 200 50 "-" "Go-http-client/1.1" 0.000 848`
192.168.1.102 - - [25/Feb/2017:21:06:15 +0100] "GET /api/v1/dataspaces/gotoconf/queryjobs/855620e9-1d1f-4b0e-91fe-c348795e68c9 HTTP/1.1" 200 591 "referrer" "Mozilla/5.0" 0.008 995
```

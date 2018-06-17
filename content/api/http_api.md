---
title: "HTTP API"
---

## Overview

This page provides information about the HTTP API that Humio provides.

### Variables

This documentation uses the following variables to show
places where you should replace the data in each example request with your own data:

* `$REPOSITORY_NAME`: The name of a repository, e.g `nginx-logs` or `myapplication`.
* `$API_TOKEN`: Your [API token](#api-token).
* `$PARSER`: The identifier of a specific parser.

### Available Endpoints

TODO

### HTTP Headers


This section describes the HTTP headers that you can use with the Humio API.


### API Token

To use the HTTP API, you must provide an API token using the `Authorization` header.

{{% notice note %}}
You can find your API token on the web application's front page (after login)
by clicking the 'Account', then the 'Show' button.
![API Token](/images/api-token.png)
{{% /notice %}}

Example:

```shell
curl https://demo.humio.com/api/v1/dataspaces/github/query \
 -X POST \
 -H 'Content-Type: application/json' \
 -H "Authorization: Bearer $API_TOKEN" \
 -d '{"queryString":"count()"}'
```

You can also use [API Token for Local Root Access]({{< relref "root-access.md#root-token" >}}).

### GZIP Compression

All API calls should use GZIP compression by passing a `Accept-Encoding` header,
e.g.:

```shell
curl https://demo.humio.com/api/v1/dataspaces/github/query \
 -X POST \
 -H 'Content-Type: application/json' \
 -H "Authorization: Bearer $API_TOKEN" \
 -H 'Accept-Encoding: gzip' \
 -d '{"queryString":"count()"}'
```
<!-- To request a gzip compressed response -->

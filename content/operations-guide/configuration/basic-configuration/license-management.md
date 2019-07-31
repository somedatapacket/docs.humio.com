---
title: "License Management"
weight: 101
aliases: ["/configuration/license-management"]
---

Once you have purchased a license for running Humio on premises you will need
to install your license key.

Don't worry if you do not have a license key, you can run Humio in
Trial Mode and Humio will keep all your data once you install your license.

You can install a key either through the Administration interface in the UI,
or through an API call.

If you are running Humio in a cluster setup, you only have to add the the key
on a single node, it will be automatically propagated to all cluster nodes.

## Managing your license in the UI

From the account menu in the top right corner of the UI select:

`Administration` __→__ `License`

In the view you can paste in the license key. Extra line breaks and white space is ignored.

## Using the API

Here is an example of updating the license key using CURL:

```shell
LICENSE_KEY="....."
TOKEN=`cat /data/humio-data/local-admin-token.txt`
curl -v -X POST -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "{ \"query\": \"mutation { updateLicenseKey(license: \\\"$LICENSE_KEY\\\") { expiresAt } }\" }" \
  $BASEURL/graphql
```

This will return status 200 and the date your license expires.

## Expired Licenses

The UI will warn you 30 days before the license expires.

If you license runs out, Humio will continue accepting ingest data while
your license is renewed - but the search interval will be restricted.

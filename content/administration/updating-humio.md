---
title: Updating Humio to a newer version
---

This guide will take you through the steps required to upgrade your Humio Cluster
to a newer version.

You should always check the [Release Notes]({{< ref "release-notes/_index.md" >}})
for the all versions between the version on Humio you are currently running
and the version you are installing.

Some versions are marked with __Data Migrations__ indicating that Humio's
internal database will be migrated to a new schema. This is usually one way
and that implies you cannot easily downgrade if you have issues with the new
version!

# Steps to Updating your Cluster

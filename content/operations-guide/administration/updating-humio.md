---
title: Updating Humio to a newer version
weight: 90
aliases: ["/administration/updating-humio", "configuration/upgrading"]
---

This guide will take you through the steps required to upgrade your Humio Cluster
to a newer version.

You should always check the [Release Notes]({{< ref "release-notes/_index.md" >}})
for the all versions between the version on Humio you are currently running
and the version you are installing.

## Data Migrations

Some versions are marked with __Data Migrations__ indicating that Humio's
internal database will be migrated to a new schema. This is usually one way
and that implies you cannot easily downgrade if you have issues with the new
version!

WARNING: If a version is marked as having data migrations you will need to update all nodes
at the same time, else you might corrupt the cluster's metadata!
This means taking all nodes offline while updating. Hopefully all clients are configured
with data retransmission, e.g. using FileBeat or similar, so you should not see any data loss.

## Steps to updating a node

Upgrading Humio is a matter of stopping the old running version and
starting the new version, on top of the same data directories, and
with the same configuration, in most cases. Some releases have
instructions in their release notes on required steps to upgrade, but
most releases should just run on top of the previous one.

We recommend that you make a backup copy of the file `$DATA_DIR/humio-data/global-data-snapshot.json`
before you upgrade - preferably after shutting down the old version but before starting the new one.
This file may come in handy if something goes wrong.
This file can be used to roll back to the previous version.

### Running in Docker

When using Docker images to run Humio, upgrade by pulling the latest
version of the Docker image and running it using the same Docker
arguments as previously.

All Humio images are tagged with a version. You should specify the version
of the image when you run it. In the example below "latest" is used as version.

#### Example

This example shows how to upgrade the "single image" Docker version,
where everything is inside a single Docker container.

```shell
docker stop humio | true
docker rm humio | true
docker pull humio/humio:latest
docker run -v $HOST_DATA_DIR:/data --net=host --detach --restart=always --name=humio --env-file=$PATH_TO_CONFIG_FILE humio/humio
```

### Running from Java JAR

When running the Humio jar outside Docker, download the latest version and
restart the java process on the new Jar file.

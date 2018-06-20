---
title: Upgrading
---


Upgrading Humio is a matter of stopping the old running version and
starting the new version, on top of the same data directories, and
with the same configuration, in most cases. Some releases have
instructions in their release notes on required steps to upgrade, but
most releases should just run on top of the previous one.

{{% notice note %}}
We recommend that you make a backup copy of the file ${HOST_DATA_DIR}/humio-data/global-data-snapshot.json when upgrade, preferably after shutting down the old version but before starting the new one. This may come in handy, if something goes wrong during the upgrade, as you may need the old version, if you decide to roll back to the previous version.
{{% /notice %}}

When using Docker images to run Humio, upgrade by pulling the latest
version of the Docker container and running it using the same Docker
arguments.

When running the Humio jar outside Docker, download the latest version and restart the java process on the new jar.


{{% notice note %}}
All Humio images are tagged with a version. You should specify the version
of the image when you run it. In the example below "latest" is used as version.
{{% /notice %}}

This example shows how to upgrade the "single image" Docker version,
where everything is inside a single Docker container.

```shell
docker stop humio | true
docker rm humio | true
docker pull humio/humio:latest
docker run -v $HOST_DATA_DIR:/data --net=host --detach --restart=always --name=humio --env-file=$PATH_TO_CONFIG_FILE humio/humio
```

---
title: Upgrading
---

To upgrade Humio, pull the latest version of the Docker container and run it using the same Docker arguments, especially the same data directories.

{{% notice note %}}
All Humio images are tagged with a version. You should specify the version of the image when you run it. In the example below latest is used.
{{% /notice %}}

```shell
docker stop humio | true
docker rm humio | true
docker pull humio/humio:latest
docker run -v $HOST_DATA_DIR:/data --net=host --detach --restart=always --name=humio --env-file=$PATH_TO_CONFIG_FILE humio/humio
```

[![Build Status](https://drone.humio.cloud/api/badges/humio/docs.humio.com/status.svg)](https://drone.humio.cloud/humio/docs.humio.com)

# docs.humio.com
Official documentation for Humio

## Building docs
First, you need to make sure you have [Docker installed](https://docs.docker.com/install/) on your machine.
Then you can preview the docs by running

```
$ make run
```
which will expose the documentation at [localhost:1313](http://localhost:1313).

## Updating online docs
All changes to the master branch are almost immediately deployed to [docs.humio.com](https://docs.humio.com).

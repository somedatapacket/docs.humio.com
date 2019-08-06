[![Build Status](https://drone.humio.cloud/api/badges/humio/docs.humio.com/status.svg)](https://drone.humio.cloud/humio/docs.humio.com)

# docs.humio.com
Official documentation for Humio

## Prerequisites
* [Docker](https://docs.docker.com/install/)
* [Hugo](https://gohugo.io/)

If using MacOS and [Homebrew](https://brew.sh/), simply run:

```
brew install docker hugo
```

## Building docs
Preview the documentation at [localhost:1313](http://localhost:1313) by running:

```
$ make run
```

## Updating online docs
All changes to the master branch are almost immediately deployed to [docs.humio.com](https://docs.humio.com).

#!/bin/bash

docker run --rm --name "docs.humio.com" -p 1313:1313 \
  --volume $(pwd):/src \
  --volume /tmp/hugo-build-output:/output \
  --env HUGO_WATCH=true \
  --env ARGS="--disableFastRender" \
  jojomi/hugo

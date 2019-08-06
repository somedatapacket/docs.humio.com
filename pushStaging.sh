#!/usr/bin/env bash
git push -f origin "$(git branch | grep -F \* | cut -d ' ' -f2):staging"

#sleep 5 #Give Drone some time to start the build
#BUILD=$(drone build ls --format '{{ .Number }}' --status=running --branch=staging humio/docs.humio.com | grep $(git rev-parse HEAD))

#drone build info --format '{{ .Status }}' humio/docs.humio.com "${BUILD}"
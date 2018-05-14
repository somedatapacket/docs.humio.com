---
title: "Kubernetes"
---


Take advantage of Humio with our Kubernetes setup!

To do this we’ll need to be sure the package manager for Kubernetes is installed — Helm. Directions for installing Helm for your particular OS flavor can be found on the [Helm Github page](https://github.com/kubernetes/helm).

Once Helm is setup, take your ingest token from your Humio Dataspace page…

![Humio Data Space](/images/token.png)

…and add it to the [humio-agent.yaml](https://gist.github.com/mwl/134b813769878067dde77ac3f26a1f2b#file-humio-agent-yaml) file in the directory where your Kubernetes cluster and Helm are being run from.



Finally, we run a simple Helm command to get the logs rolling:

`helm install stable/fluent-bit --name=humio-agent -f humio-agent.yaml`


Once this is in place, your logs should be up and running.

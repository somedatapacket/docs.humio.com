---
title: Running Humio on Kubernetes
menuTitle: Kubernetes
weight: 410
categories: ["Integration", "Platform"]
---

{{% notice note %}}
If you are looking for how to ship data from a Kubernetes cluster to Humio, please see our [Kubernetes platform integration documentation](/integrations/platform-integrations/kubernetes).
{{% /notice %}}

<img src="/integrations/kubernetes.svg" width="100" height="100" style="float: right" />
At this time we do not recommend running Humio inside a Kubernetes cluster. We are exploring approaches for deploying both standalone and clustered Humio environments on Kubernetes and will provide best practices in the future.

## Community Resources
If you would like to experiment with running Humio on Kubernetes today you can reference a community based effort by Kasper Nissen of Lunar Way that utilizes Helm and Minikube. You can find his project on [GitHub](https://github.com/kaspernissen/k8s-humio). 

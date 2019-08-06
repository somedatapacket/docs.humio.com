---
title: Running Humio on Kubernetes
menuTitle: Kubernetes
weight: 410
categories: ["Integration", "Platform"]
aliases: ["/installation/kubernetes_deployment"]
---

{{% notice note %}}
If you are looking for how to ship data from a Kubernetes cluster to Humio without running Humio in Kubernetes, please
see our [Kubernetes platform integration documentation](/integrations/platform-integrations/kubernetes).
{{% /notice %}}

<img src="/integrations/kubernetes.svg" width="100" height="100" style="float: right" />
At this time running Humio inside a Kubernetes cluster is considered experimental and not recommended for production.

## Installation Using Helm

The easiest way to install Humio in Kubernetes is using the offical Humio helm charts.

Directions for installing Helm for your particular OS flavor can be found on the
[Helm Github page](https://github.com/kubernetes/helm).


Once that is done it will be necessary to update the main helm chart repository. This main repository contains subcharts
for Humio.
{{% notice note %}}
We depend on the [Confluent Helm Charts](https://github.com/confluentinc/cp-helm-charts) as dependencies, which are
included automatically when running the installation below.
{{% /notice %}}

```
helm repo add humio https://humio.github.io/humio-helm-charts
helm repo update
```

Now create a `values.yaml` file with the following content:
```yaml
---
humio-core:
  enabled: true
humio-fluentbit:
  enabled: true
  es:
    autodiscovery: true
global:
  sharedTokens:
    fluentbit: {kubernetes: in-cluster}
```

These settings will tell Helm to create a default 3 node Humio cluster with kafka and zookeeper. It will also create a
fluentbit daemonset that will collect logs from any pods running in the Kubernetes cluster, and autodiscover the Humio
endpoint and token. We recommend installing Humio into its own namespace, in this example we're using the "logging"
namespace:
```
helm install -f values.yaml humio/humio-helm-charts --name humio --namespace logging
```

### Logging In Following Installation

There are a couple ways to get the URL for a Humio cluster. In most cases, grabbing the load balancer URL is sufficient:
```shell
kubectl get service humio-humio-core-http -n logging -o go-template --template='http://{{(index .status.loadBalancer.ingress 0 ).ip}}:8080'
```

If you're running in minikube, run this command instead:
```shell
minikube service humio-humio-core-http -n logging --url
```

If `humio-core.authenticationMethod` is set to `single-user` (default), then you need to supply a username and password
when logging in. The default username is `developer` and the password can be retrieved from the command:
```
kubectl get secret developer-user-password -n logging -o=template --template={{.data.password}} | base64 -D
```
{{% notice note %}}
The base64 command may vary depending on OS and distribution.
{{% /notice %}}

### Additonal Helm Customization

It may be necessary to create a custom helm `values.yaml` file to adjust from the default settings.

Below is an example of a custom `values.yaml` file with various customizations. For a full list of customizations,
reference the helm chart.
```
---
humio-core:
  enabled: true

  # Use 5 Humio nodes rather than the default of 3.
  replicas: 5

  # Disable single-user mode so Humio is open with no authentication.
  authenticationMethod: ""

  # Use a custom version of Humio.
  image: humio/humio-core:<version>

  # Custom bloomfilter options.
  bloomfilter:
    enabled: true
    backfillingEnabled: true

  # Custom partitions
  ingest:
    initialPartitionsPerNode: 2
  storage:
    initialPartitionsPerNode: 2

  # Custom CPU/Memory resources
  resources:
    limits:
     cpu: 2
     memory: 4Gi
    requests:
     cpu: 2
     memory: 4Gi

  # Custom JVM memory settings
  jvm:
    xss: 4m
    xms: 512m
    xmx: 3072m

  # Custom Affinity Policies
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node_type
            operator: In
            values:
            - humio

# Disable the fluentbit daemonset
humio-fluentbit:
  enabled: false
```

## Uninstalling

{{% notice warning %}}
This will destroy all Humio data.
{{% /notice %}}
```
helm delete --purge humio
kubectl delete namespace logging --cascade=true
```

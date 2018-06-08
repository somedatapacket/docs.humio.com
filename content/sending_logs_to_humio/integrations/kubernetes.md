---
title: "Kubernetes"
---

When it comes to managing microservices in a Kubernetes cluster, Humio is a great way to get insights into your applications. While other log shippers are supported we mainly focus on using [Fluent Bit](https://fluentbit.io) for forwarding log messages to Humio. 

If you're relatively new to Kubernetes, we recommend using the [Helm](#helm) method of installation. If you want more control we recommend the [advanced installation](#advanced-installation) method

## Helm

Take advantage of Humio with your Kubernetes setup!

We'll start with Helm, the Kubernetes package manager. Directions for installing Helm for your particular OS flavor can be found on the [Helm Github page](https://github.com/kubernetes/helm).

Next, create a file named `humio-agent.yaml` with the following content:

```yaml
backend:
  type: "es"
  es:
    host: "<humio-host>"
    http_user: "<ingest-token>"
    http_passwd: "none"
    tls: on
    tls_verify: on
    tls_ca: |
      -----BEGIN CERTIFICATE-----
      MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
      MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
      DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
      PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
      Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
      AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
      rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
      OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
      xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
      7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
      aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
      HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
      SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
      ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
      AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
      R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
      JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
      Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
      -----END CERTIFICATE-----
```
Replace `<humio-host>` with the hostname of your Humio installation (i.e. `cloud.humio.com`). For on-prem installation don't forget to enable the [`ELASTIC_PORT` property](/operation/installation/configuration_options.md).
Take your ingest token from your Humio Dataspace page…

![Humio Data Space](/images/token.png)

…and replace `<ingest-token>` with the ingest token.

Finally, we run a simple Helm command to get the logs rolling:

```bash
$ helm install stable/fluent-bit --name=humio-agent -f humio-agent.yaml
```

Once this is in place, your logs should be up and running.

### Uninstall Chart

Should you want to uninstall the pod, it can be done with the following command

```bash
$ helm delete --purge humio-agent
```

## Advanced installation

The fine guys at Fluent has gone ahead a written a very handy guide for [installing Fluent Bit on Kubernetes](https://github.com/fluent/fluent-bit-kubernetes-logging), but a few deviations to the guide are required to make it work with Humio.

{{% notice info %}}
Make sure that you have [uninstalled the Chart](#uninstall-chart) if you went through the Helm installation method. 
{{% /notice %}}

Start by creating a namespace and configure service accounts, roles etc.

```bash
$ kubectl create namespace logging
$ kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-service-account.yaml
$ kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role.yaml
$ kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role-binding.yaml
$ kubectl create -f https://docs.humio.com/kubernetes-files/fluent-bit-configmap.yaml
``` 

Create a new file, named `fluent-bit-ds.yaml` with the following content
```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: logging
  labels:
    k8s-app: fluent-bit-logging
    version: v1
    kubernetes.io/cluster-service: "true"
spec:
  template:
    metadata:
      labels:
        k8s-app: fluent-bit-logging
        version: v1
        kubernetes.io/cluster-service: "true"
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "2020"
        prometheus.io/path: /api/v1/metrics/prometheus
    spec:
      containers:
      - name: fluent-bit
        image: fluent/fluent-bit:0.13.2
        imagePullPolicy: Always
        ports:
          - containerPort: 2020
        env:
        - name: FLUENT_ELASTICSEARCH_HOST
          value: "<humio-host>"
        - name: FLUENT_ELASTICSEARCH_PORT
          value: "9200"
        - name:  FLUENT_ELASTICSEARCH_TLS
          value: "On"
        - name: HUMIO_INGEST_TOKEN
          value: "<humio-ingest-token>"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc/
      terminationGracePeriodSeconds: 10
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
      serviceAccountName: fluent-bit
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
```

Don't forget to replace `<humio-host>` with the hostname of your Humio instance, i.e. `cloud.humio.com` and `<ingest-token>` with your [Humio ingest-token](/sending_logs_to_humio/ingest_token/).

{{% notice note %}}
Remember if you're an on-prem solution without TLS, the `FLUENT_ELASTICSEARCH_TLS` property should be switched to `Off`.
{{% /notice %}}

Finally, you need to install the daemonset

```bash
$ kubectl create -f fluent-bit-ds.yaml
```

Your container logs should now start to roll into Humio

### Additional filters
In some cases you might want to make some changes to the Fluent Bit configuration. Easiest way to do that is changing the configmap by opening it in an editor with the following command

```bash
$ kubectl -n logging edit Configmap fluent-bit-config
```

Make your changes, for instance adding another filter, which will rename the `log` field to `rawstring`. Add the following to the bottom of the `data.filter-kubernetes.conf` section.
```
    [FILTER]
        Name                Modify
        Match               *
        Rename              log rawstring
```

Save and exit your editor and restart Fluent Bit with

```bash
$ kubectl -n logging delete pod -l k8s-app=fluent-bit-logging
```

### Uninstall

Since everything is installed in a namespace, uninstalling Fluent Bit is pretty simple

```bash
$ kubectl delete namespace logging
$ kubectl delete clusterrole fluent-bit-read
$ kubectl delete clusterrolebindings fluent-bit-read
```
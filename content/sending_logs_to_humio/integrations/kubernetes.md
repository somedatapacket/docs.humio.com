---
title: "Kubernetes"
---

Take advantage of Humio with our Kubernetes setup!

To do this we’ll need to be sure the package manager for Kubernetes is installed - Helm. Directions for installing Helm for your particular OS flavor can be found on the [Helm Github page](https://github.com/kubernetes/helm).

Once Helm is setup, create a file named `humio-agent.yaml` with the following content:
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

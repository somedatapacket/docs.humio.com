---
title: "Moving from Elastic Stack"
weight: 2
---

If you are an existing user of the Elastic Stack, be it either Filebeat or Logstash, together with Elastic Search this is the page for you.

Humio offers a drop-in replacement for the Elastic Search bulk API, meaning that switching your existing Filebeat or Logstash configurations over to Humio are very easy.

## Setting up Humio

First of all you will need to have access to a [repository]({{< relref "getting_started/repositories.md" >}}) in Humio.

The quickest way to get started using Humio is to create an account in [Humio Cloud](https://cloud.humio.com), where you will get a personal [Sandbox Repository]({{< relref "getting_started/the_sandbox.md" >}}) for free.

Alternatively you can choose to run our [Docker image](/operation/installation/) on your own infrastructure.

## Beats

Since you are running elasticsearch, you probably know the [Beats](https://www.elastic.co/products/beats) platform
already. You will have to reconfigure it to contains something like this:

```yaml
output.elasticsearch:
  hosts: ["elasticsearch:9200"]
```

To make all beats point to Humio, just change the `output.elasticsearch` section to:

```yaml
output.elasticsearch:
  hosts: ["https://<HOST>:443/api/v1/dataspaces/<REPOSITORY_NAME>/ingest/elasticsearch"]
  username: <INGEST_TOKEN>
```

Where `<HOST>` should be replaced with the hostname of your Humio cluster.
For our Humio Cloud use `cloud.humio.com`.

{{% notice note %}}
Make sure that the port is set to `443`. Beats' default port is `9200`!
{{% /notice %}}

`<REPOSITORY_NAME>` is the repository you want to store you data in, e.g.
`sandbox` if you want to use your personal repository.

Finally, `<INGEST_TOKEN>` should be replace with an __Ingest Token__ from the repository.
If your repository is still empty your a dialog on the search page will contain your default ingest token:

![Empty Repository Dialog](/images/dataspacewelcomewithingesttoken.png)

If you cannot find it there, you can always go to _Settings_ for your repository
and create a new Ingest Token from there.

For more information about the Beats data shippers, please take a look at [Beats section](/sending-data/log_shippers/beats/).

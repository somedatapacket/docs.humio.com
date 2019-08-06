---
title: AWS
menuTitle: AWS
pageImage: /integrations/aws.svg
weight: 200
categories: ["Integration", "Platform"]
categories_weight: 1
beta: true
aliases: ["/installation/aws"]
---


You can install Humio manually following the steps found in [overall
installation guide](/installation), but we also provide a couple of
easy installation options for AWS.

{{% notice note %}}

If you want to ship logs from ***AWS CloudWatch*** to Humio see the [AWS
CloudWatch Logs]({{< ref "aws-cloudwatch.md" >}}) integration.

{{% /notice %}}

## Quick Start - Single Node Trial
Use the following "Launch Stack" button to quickly try Humio on a new
instance using a CloudFormation Template.

[![Install Humio on AWS](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png "Install Humio on AWS")](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=Humio&templateURL=https://s3-eu-west-1.amazonaws.com/humio-aws-quick-start/single-server-cloud-formation.json)

The template will create an instance and a data volume and start Humio
in single-user mode.

When the template is done you can click on the output link to log into
Humio - give it a few moments to start.

{{< figure src="/pages/installation/aws/template-output.png" >}}

Log-in using the `developer` user and use the EC2 instance ID of node running Humio as password.

Humio will listen for HTTP traffic on port 8080, but behind a
single-user login page. You can restrict access based on IP range if
wanted. For a production setup we advise you to put a HTTPS proxy in
front of Humio or place it inside your VPC.

### Sizing

Choosing the right instance size depends on your ingest volume and
usage patterns. As a general guideline the following table is a
starting point for sizing your Humio instance.

- Up to 15 GB/day: m4.large
- Up to 35 GB/day: m4.xlarge
- Up to 75 GB/day: m4.2xlarge
- Up to 150 GB/day: m4.4xlarge

### GitHub

You can see the CloudFormation template on GitHub:

https://github.com/humio/aws-quick-start

## AWS Marketplace

Humio is available directly from the AWS Marketplace:

https://aws.amazon.com/marketplace/pp/B07DCZKMHQ

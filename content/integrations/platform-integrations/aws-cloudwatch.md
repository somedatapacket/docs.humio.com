---
title: AWS CloudWatch Logs
menuTitle: AWS CloudWatch Logs
categories: ["Integration", "Platform"]
pageImage: /integrations/cloudwatch.svg
beta: true

---

Humio's CloudWatch integration sends your ***AWS CloudWatch*** Logs to Humio by using
an AWS Lambda function to ship the data.

The integration is available from GitHub:

https://github.com/humio/cloudwatch2humio

## Quick Start

Use the Launch Stack buttons below to install in a region of your
choice.

{{% notice note %}}

Use a **globally unique** stack name. The integration uses an S3 bucket
and bucket names in S3 needs to be globally unique.

{{% /notice %}}

The integration uses a set of AWS Lambdas and you need to manually
send a test event to the [AutoSubscriber]({{< ref "#autosubscriber"
>}}) and [CloudwatchBackfiller]({{< ref "#cloudwatchbackfiller" >}})
in order to enable them.

You can send a test event using the Lambda part of the AWS
Console. The content of test event does not matter.

{{< figure src="/pages/integrations/platform-integrations/aws-cloudwatch/test-event-lambda.png" >}}


### Launch


| Region                            |                               |
|-----------------------------------|-------------------------------|
| US East (N. Virginia) - US East 1 | [![Install cloudwatch2humio in US East 1](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png "Install cloudwatch2humio in US East 1")](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=cloudwatch2humio&templateURL=https://humio-public-us-east-1.s3.amazonaws.com/cloudformation.json) |
| US East (Ohio) - US East 2 | [![Install cloudwatch2humio in US East 2](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png "Install cloudwatch2humio in US East 2")](https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/new?stackName=cloudwatch2humio&templateURL=https://humio-public-us-east-1.s3.amazonaws.com/cloudformation.json) |
| US West (Oregon) - US West 2 | [![Install cloudwatch2humio in US West 2](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png "Install cloudwatch2humio in US West 2")](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=cloudwatch2humio&templateURL=https://humio-public-us-east-1.s3.amazonaws.com/cloudformation.json) |
| EU (Frankfurt) - EU Central 1 | [![Install cloudwatch2humio in EU Central 1](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png "Install cloudwatch2humio in EU Central 1")](https://console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/new?stackName=cloudwatch2humio&templateURL=https://humio-public-us-east-1.s3.amazonaws.com/cloudformation.json) |
| EU (Ireland) - EU West 1 | [![Install cloudwatch2humio in EU West 1](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png "Install cloudwatch2humio in EU West 1")](https://console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/new?stackName=cloudwatch2humio&templateURL=https://humio-public-us-east-1.s3.amazonaws.com/cloudformation.json) |
| EU (London) - EU West 2 | [![Install cloudwatch2humio in EU West 2](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png "Install cloudwatch2humio in EU West 2")](https://console.aws.amazon.com/cloudformation/home?region=eu-west-2#/stacks/new?stackName=cloudwatch2humio&templateURL=https://humio-public-us-east-1.s3.amazonaws.com/cloudformation.json) |

If your region is missing contact us via
[mail](mailto://support@humio.com) or
[Slack](https://community.humio.com).


## Launch Parameters

The integration is installed using a CloudFormation template.

The template supports the following parameters:

* `HumioHost` - The host you want to ship your Humio logs to.
* `HumioDataspaceName` - The name of the repository in Humio that you
  want to ship logs to.
* `HumioAutoSubscription` - Enable automatic subscription to new log
  groups.
* `HumioIngestToken` - The value of your ingest token from your Humio
  account.
* `HumioSubscriptionBackfiller` - This will check for missed or old
  log groups that existed before the Humio integration will
  install. This increases execution time of the lambda by about
  1s. Defaults to **true**.
* `HumioProtocol` - The transport protocol used for delivering log
  events to Humio. `HTTPS` is default and recommended, but `HTTP` is
  possible as well.
* `HumioSubscriptionPrefix` - By adding this filter the Humio Ingester
  will only subscribe to log groups whose paths start with this
  prefix.


## How this integration works

The integration will install three lambda functions, the
`AutoSubscriber`,`CloudwatchIngester` and the
`CloudwatchBackfiller`. The CloudFormation template will also set up
CloudTrail and an S3 bucket for your account. We need this in order to
trigger the Auto Subscription lambda to newly created log groups.

### CloudwatchIngester

This lambda handles the delivery of your CloudWatch log events to
Humio.

### AutoSubscriber
This lambda will auto subscribe the CloudwatchIngester every time a
new log group is created. This is done by filtering CloudTrail events
and triggering the AutoSubscriber lambda every time a new log group is
created.

### CloudwatchBackfiller
This will run if you have set `HumioSubscriptionBackfiller` to `true`
when executing the CloudFormation template. This function will
paginate through your existing CloudWatch log groups and subscribe the
CloudwatchIngester to every single one.

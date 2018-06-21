---
title: "FAQ"
weight: 7
pre: "<b>7. </b>"
---

<b>Q: Is Humio cloud only? Is it possible to use Humio on prem?</b>

A: Humio is a flexible log management solution. We have customers that use our cloud solution, on prem solutions, and hybrids of both options. Consider what works best for your application and organization and we are happy to help you find the set up to best suit your needs.

<hr noshade>

<b>Q: If we use other logging like Elastic Stack, is it easy to move over to Humio?</b>

A: Moving to Humio is easy! We have several common integrations to bring your logs into Humio and we even have a guide on [moving from Elastic Stack to Humio](https://docs.humio.com/getting_started/moving_from_elastic_stack/) - it's as easy as following a few steps to getting your logs flowing.

<hr noshade>

<b>Q: Is Humio container ready?</b>

A: Humio was built with containerization in mind! With integrations and existing setup for Kubernetes, Humio is a solution focused on modern deployment solutions.

<hr noshade>

<b>Q: What common log shipping solutions does Humio use?</b>

A: While this list is not exhaustive, Humio recommends [Beats](http://localhost:1313/sending_logs_to_humio/log_shippers/beats/), [Logstash](http://localhost:1313/sending_logs_to_humio/log_shippers/logstash/), or [Ryslog](http://localhost:1313/sending_logs_to_humio/log_shippers/rsyslog/) for shipping your logs. We can take advantage of other solutions, but these are the most common we've experienced.

<hr noshade>

<b>Q: Does Humio integrate with any notification systems?</b>

A: Humio integrates with several common notification methods including [email, Slack, and extrenal services like OpsGenie](http://localhost:1313/features/alerts/notifiers/). If you need Humio to work with your particular notification system, contact our support team!

<hr noshade>

<b>Q: What happened to "Dataspaces"</b>

A: "Repository" is the new term. What used to be a "dataspace" in Humio is now a [Repository]({{< relref "getting_started/repositories.md" >}}).

The HTTP API includes the path `/api/v1/dataspaces/$REPOSITORY_NAME/` to be compatible with existing clients.
In this context, the `$REPOSITORY_NAME` variable is the name of the repository. (It used to be the name of the dataspace).


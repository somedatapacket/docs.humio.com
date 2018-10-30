---
title: "FAQ"
weight: 7
aliases: ["appendix/faq", "ref/faq"]
---

<b>Q: Is Humio cloud only? Is it possible to use Humio on premises?</b>

A: Humio is a flexible log management solution. We have customers that use our
cloud solution, on-prem solutions, and hybrids of both options. Consider what
works best for your application and organization and we are happy to help you
ind the set up to best suit your needs.

<hr noshade>

<b>Q: If we use other logging like Elastic Stack, is it easy to move over to Humio?</b>

A: Moving to Humio is easy! We have several common integrations to bring your
logs into Humio and we even have a guide on
[moving from Elastic Stack to Humio]({{< ref "moving-from-elastic-stack.md" >}}) -
it's as easy as following a few steps to getting your logs flowing.

<hr noshade>

<b>Q: Is Humio container ready?</b>

A: Humio was built with containerization in mind! With integrations and
existing setup for Kubernetes, Humio is a solution focused on modern
deployment solutions.

<hr noshade>

<b>Q: What common log shipping solutions does Humio use?</b>

A: While this list is not exhaustive, Humio recommends [Beats]({{< ref "integrations/data-shippers/beats/_index.md" >}}),
[Logstash]({{< ref "logstash.md" >}}), or [Ryslog]({{< ref "rsyslog.md" >}}) for
shipping your logs. We can take advantage of other solutions, but these are the
most common we've experienced.

<hr noshade>

<b>Q: Does Humio integrate with any notification systems?</b>

A: Humio integrates with several common notification methods
including [email, Slack, and external services like OpsGenie]({{< ref "alerts/_index.md" >}}).
If you need Humio to work with your particular notification system, contact our support team!

<hr noshade>

<b>Q: What happened to "Dataspaces"</b>

A: "Repository" is the new term. What used to be a "dataspace" in Humio is now a [Repository]({{< ref "repositories.md" >}}).

The HTTP API includes the path `/api/v1/dataspaces/$REPOSITORY_NAME/` to be compatible with existing clients.
In this context, the `$REPOSITORY_NAME` variable is the name of the repository. (It used to be the name of the dataspace).


<hr noshade>

<b>Q: Can I run Humio on IPv6-only, IPv4-only or both?</b>

A: Humio runs on either or both IP versions, depending on what you specify using `HUMIO_JVM_ARGS`. By default the process binds on both IPv4 and IPv6.

If you use the Docker images provided by Humio for Kafka and Zookeeper, or run the "humio/humio" image that includes both of them,
you need to make sure those processe also get the same options regarding IP protocol as the Humio process.

IPv4 Only:
```
HUMIO_JVM_ARGS=-Djava.net.preferIPv4Stack=true
KAFKA_OPTS=-Djava.net.preferIPv4Stack=true
ZOOKEEPER_OPTS=-Djava.net.preferIPv4Stack=true
```

IPv6 Only:
```
HUMIO_JVM_ARGS=-Djava.net.preferIPv6Addresses=true
KAFKA_OPTS=-Djava.net.preferIPv6Addresses=true
ZOOKEEPER_OPTS=-Djava.net.preferIPv6Addresses=true
```

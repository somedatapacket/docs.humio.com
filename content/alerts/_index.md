---
title: "Alerts"
weight: 675
category_title: Overview
aliases: ["/features/alerts/notifiers/"]
---
Humio has built-in support for alerting.
Every repository has it's own individual set of alerts.
The alert concept in Humio consists of two parts: *Notifiers* and *Alerts*.

Notifiers are the integration between Humio and _other_ systems. Currently e-mail
notifications and webhooks are supported along with a list of dedicated
integrations e.g. [Slack]({{< ref "slack.md" >}}).   

For instance, when an alert detects your accesslog has reached a set threshold
for Internal Server Errors, it will trigger a notifier that will send a message informing about the issue .

## Alerts

Alerts are standard Live Queries that run continuously.
Alerts trigger whenever there is one or more rows in the search result.

**Example**
For instance an alarm can be configured to trigger whenever there's more than 5
status 500s in the accesslog.  

```humio
#type=accesslog statuscode=500
| count(as=internal_server_errors)
| internal_server_errors > 5
```

If there's less than 5 events in the time window the search will be an empty
result and nothing will happen.
On the other hand, if there's more than five events a non-empty result will be
returned and then alert will trigger the notifier.

## Types of alerts

Generally speaking, alerts can be divided into two groups:

*  Single events, that can affect one or more users experience with the product.
   Usually not something that should wake up engineers at night but could result
   in an ticket on your issue tracker.
*  Faulty state is when one or more components has reached a bad state and is
   unable to function properly. This usually affects most users and is something
   that should wake up engineers at night.

### Being Notified

When alerts trigger they are configured to send notifications using a notifier.

### Creating Alerts

The easiest way to create a new alert is by building up your query in the Search view.
Don't forget to set a Live time window for the search. And then hit the `Save As…` __→__ `Alert` option on the right.

Then give it a name, select a notifier and finally Notification Frequency.
The Notification Frequency is the minimum time before the same alert will be triggered again.

{{% notice tip %}}
For notifiers like E-mail and Slack you want a lower Notification Frequency (more time in-between) triggers since they don't do de-duplication.
{{% /notice%}}

<!--TODO: When Auto-cancel has been implemented, please reconsider guideline on Notification Frequency -->

## Notifiers

A notifier is a module that sends notifications when alerts trigger.


### Built-in Notifiers

Our list of notifiers is ever growing and currently we do support the following services.

* [Email]({{< ref "email.md" >}})
* [Slack]({{< ref "slack.md" >}})
* [Webhook]({{< ref "webhook.md" >}})
* [OpsGenie]({{< ref "opsgenie.md" >}})
* [PagerDuty]({{< ref "pagerduty.md" >}})
* [VictorOps]({{< ref "victorops.md" >}})

Creating a new Notifier is pretty simple. On the Alerts Page there's a Notifiers menu item on the left.
To create a new one hit the "New Notifier" button on the top right.

First you'll need to select a type of notifier from the "Notifier Type" dropdown list

All notifiers must be assigned a name.

{{% notice note %}}
Make sure you give your notifiers a meaningful name, i.e. "OpsTeam",
"Backlog issues" etc. We will make sure that the type of the notifier is also displayed.
{{% /notice%}}

### Custom Notifiers

If the built-in notifiers are not enough and you need to make something custom,
Humio supports webhooks that allow you to call an external service with HTTP.
You can add headers and [customize body of the message]({{< ref "#templates" >}}) as seen below.

### Message Templates {#templates}

Notifier templates are used to create the message sent by notifiers.
They currently apply to [Email]({{< ref "email.md" >}}) and [WebHook]({{< ref "webhook.md" >}}) notifiers.
The template engine is a simple "search/replace" model, where the `{…}` marked
placeholders are replaced with contextual aware variables.

See the list for an explanation of the placeholders:

| Placeholder                   | Description                                                |
|-------------------------------|------------------------------------------------------------|
| `{alert_name}`                | The user made name of the alert fired.                     |
| `{alert_description}`         | A user made description of the alert fired.                |
| `{alert_triggered_timestamp}` | The time at which the alert was triggered.                 |
| `{event_count}`               | The number of events in the query result.                  |
| `{url}`                       | A URL to open Humio with the alert's query.                |
| `{query_string}`              | The query that triggered the alert.                        |
| `{query_result_summary}`      | A summary of data in the query result.                     |
| `{query_time_interval}`       | The time interval for the alert's query. (e.g. 10m -> now) |
| `{warnings}`                  | Any warnings that was generated by the query.              |

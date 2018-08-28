---
title: "Pagerduty"
pageImage: "/integrations/pagerduty.svg"
categories: ["Integration", "OtherIntegration"]
---

Humio supports Pagerduty alerts through our Notifier system.

To create a PagerDuty Notifier you need to create a "Service"
in your PagerDuty Account (Note that you have to be an admin in PagerDuty).

You do that by performing the following steps:

1. Open `Configuration` → `Services` and select `Add New Service`.
2. Give your service a name, i.e. "Humio".
3. Under __Integration Settings__ select "Humio" in the tools dropdown.
4. Leave the rest as default and hit `Add Service`.
5. Take note of the __Integration Key__ as we'll be using that in Humio when setting up the notifier.

Back in Humio proceed with the following steps

1. Open the Repo or View for which you want to configure a notifier.
2. Select the __Alerts__ menu item and go to __Notifiers__. Hit __New Notifier__.
3. In the __Notifier Type__ drop down select PagerDuty.
4. Give the Notifier a name, i.e. "PagerDuty Critical".
5. Paste the _integration key_ from PagerDuty into the __PagerDuty Integration Key__ field.
6. Hit __Create Notifier__.

Your PagerDuty notifier is now fully configured and ready to use.

{{% notice info %}}
You can create multiple PagerDuty notifiers i.e. if you have multiple alerting channels.
{{% /notice %}}

Next, you might want to configure an [Alert]({{< ref "/alerts/_index.md" >}}).

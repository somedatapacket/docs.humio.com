---
title: "Pagerduty"
pageImage: "/integrations/pagerduty.svg"
categories: ["Integration", "OtherIntegration"]
---

Humio supports Pagerduty alerts through our Notifier system.

To create a PagerDuty Notifier you need to create a "Service"
in your PagerDuty Account (Note that you have to be an admin in PagerDuty).

In PagerDuty you can do that by going to:

1. Open `Configuration` → `Services` and select `Add New Service`.
2. Give your service a name, i.e. "Humio"
3. Under __Integration Settings__ select "Use our API directly" under __Integration Type__. "Events API v2", should be the default and also what we're using for this notifier.
4. Leave the rest as default and hit `Add Service`
5. Take note of the __Integration Key__ as we'll be using that in Humio when setting up the notifier.

Back in Humio proceed with the following steps

1. Open the Repo for View for which you want to configure a notifier.
2. Select the __Alerts__ menu item and go to __Notifiers__. Hit __New Notifier__.
3. In the __Notifier Type__ drop down, please select PagerDuty.
4. Give the Notifier a name, i.e. "PagerDuty Critical"
5. Paste the _integration key_ from PagerDuty __PagerDuty Integration Key__ field
6. Hit __Create Notifier__.

{{% notice info %}}
Your PagerDuty notifier is now fully configured and ready to use. You can create multiple PagerDuty notifiers i.e. if you have multiple pager channels.
{{% /notice %}}

Next, you might want to configure an [Alert]({{< ref "/alerts/_index.md" >}}).
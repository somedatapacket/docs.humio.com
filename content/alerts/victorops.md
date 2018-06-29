---
title: "VictorOps"
pageImage: "/integrations/victorops.svg"
categories: ["Integration"]
---

Humio supports VictorOps alerts through our Notifier system.

To create a VictorOps Notifier you need to create a "Service"
in your VictorOps Account.

You do that by performing the following steps:

1. Open `Configuration` → `Alert Behaviour` → `Integrations`
2. Select Humio in the list of integrations and hit __Enable Integration__.
3. Copy the _Service Endpoint API_ url.

Back in Humio proceed with the following steps

1. Open the Repo for View for which you want to configure a notifier.
2. Select the __Alerts__ menu item and go to __Notifiers__. Hit __New Notifier__.
3. In the __Notifier Type__ drop down, please select VictorOps.
4. Give the Notifier a name, i.e. "VictorOps Critical"
5. Paste the _Service Endpoint API_ url from VictorOps into the __Service Endpoint API__ field, and replace `$routing_key` with a [VictorOps Routing Key](https://help.victorops.com/knowledge-base/routing-keys/).
6. Hit __Create Notifier__.

Your VictorOps notifier is now fully configured and ready to use.

{{% notice info %}}
You can create multiple VictorOps notifiers i.e. if you have multiple alerting channels.
{{% /notice %}}

Next, you might want to configure an [Alert]({{< ref "/alerts/_index.md" >}}).

<!--
TODO: Describe Transmogrifier https://help.victorops.com/knowledge-base/transmogrifier-annotations/
-->

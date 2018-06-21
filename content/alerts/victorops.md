---
title: "VictorOps"
pageImage: "/integrations/victorops.svg"
categories: ["Integration"]
---

Humio supports VictorOps alerts through our Notifier system.

To create a VictorOps Notifier you need to create a "Service"
in your VictorOps Account (Note that you have to be an admin in PagerDuty).

You do that by going to:

`Configuration` __→__ `Services` → `Add New Service`.

For the "Integration Type" make sure you select "Use our API directly" and select
Event API v2" in the drop down.

Just follow the instructions for there, and when you are done, copy the Integration Key
into Humio's VictorOps notifier form under: "THE ROUTING KEY".


<!--
TODO: Describe Transmogrifier https://help.victorops.com/knowledge-base/transmogrifier-annotations/
-->

---
title: Embedding iFrame Widgets
---

You can embed a single Humio dashboard widget into an external HTML site using an iframe or in other media.

The feature relies on the security model of [Shared Secret URLs]({{ ref "sharing-dashboards.md" }}),
and you can only embed widgets that are accessible with a shared secret URL.

## Embedding a widget in an iframe

1. Add the widget you want to share to a dashboard.

Tip: You can create a special dashboard called e.g. "Embedded Widgets" and add all the widgets you
want to embed to it. That way it is easy to keep track of all exposed widgets. 

2. Create a shared secret URL for the dashboard ([Follow this guide]({{< ref "sharing-dashboards.md" >}}))

3. Visit the dashboard using the secret URL

4. Hover over the widget you want to share and click the fullscreen icon that appears.

![Icon to access a widget in fullscreen](/images/pages/dashboards/embed-widget.png)

This will make the widget go full screen and the URL in the browser's address bar can
be used for e.g. an iframe.

5. Copy the browser's address bar URL

6. Make an iframe using the copied URL

Here is an example iframe, you will need to add the URL and customize its height and width to
match your needs.

``` html
<iframe width="600" height="400" src="http://cloud.humio.com/humioshared/dashboards?token=C6OTXOXvIh5mABlznmbwmdrJ&widget=ab01ae6e-cf74-40c3-90e3-2a4436e11c12" frameborder="0" allowfullscreen></iframe>
```

## FAQ

### Do I have to make a dashboard to share a single widget

Yes, unfortunaly adding a widget to a shared dashboard is currently the only way of exposing
a widget. 
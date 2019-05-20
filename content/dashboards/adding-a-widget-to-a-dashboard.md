---
title: Adding a dashboard widget
---

Widgets are created and configured on the "Search" page and then saved to a dashboard.

You can only create dashboard widgets and modify dashboard if you have the "Administer Dashboards" permission
on the repository or view in question.

## Steps to creating a dashboard widget

1. Run a query on the search page, e.g.

```humio
timechart(hostname)
```

This will automatically select the [Time Chart]({{< ref "time-chart.md" >}}) widget type,
and you can style the widget by clicking the "Style" button on the left side of the screen.

2. Click the "Save as..." button and select "Dashboard Widget"

This will bring up a dialog asking which dashboard to add the widget. You also have the option
of creating a new dashboard for the widget.

It is important to note that the active search interval used on the search page is saved along
with the widget and will be the on dashboard.

3. Make sure the "Open Dashboard after Save" checkbox is checked.

4. Moved and resize the widget on the dashboard.

In order to position the widget you have to activate "Edit Mode" on the dashboard. You do that
by clicking the "Edit Dashboard" button in the top menu.

Now you can drag and resize until you are happy with the position and size of the widget.

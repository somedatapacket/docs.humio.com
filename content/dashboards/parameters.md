---
title: Working with Dashboard Parameters
menuTitle: Parameters
aliases: ["/ref/parameters"]
---

Dashboard parameters allow you to interact with dashboards doing filtering and do drill-down
for widgets.

Parameters are added to the query using the `?parameterName` syntax.

## Creating a parameterized dashboard

Lets say that we want to create a dashboard that monitors a set of servers and that
those servers are placed in racks and run in different availability zones.

Assuming that log entries are attributed with the following fields:

`host` - The hostname of the server.
`rackId` - The ID of the server rack.
`thread` - The thread the log entry produced on.
`zone` - The availability zone, represented with IDs such as 'eu-1', 'ca-2', 'us-1'.  
`loglevel` - The log level of the entry, such as `INFO` `WARN` and `ERROR`.

### Creating a widget with parameters

On the search page we enter a query like the one below:

```humio
host = ?host and rackId = ?rackId and zoneId=?zoneId | timechart(loglevel)
```

The query contains three parameters: `?host`, `?rackId` and `?zoneId`.

Running the query produces a time chart widget with one series per log level. This allows
us to see the activity level on servers and e.g. how many errors occur.

![Parameters in a Query](/images/pages/dashboards/query-parameters-in-query.png)

As you can see, the screenshot shows an input field has appeared per parameter and its default value is set to `*` -
meaning that it matches everything. We can now set the `?zone` parameter to e.g. `eu-1`
and run the query again to show results for all hosts and all racks but only for the `eu-1` availability zone.

You can also use the wildcard character in parameters so above we could write `eu-*` to match all
availability zones starting with "eu-".

## Adding Parameters to Dashboards

Once you are happy with your query with parameters you can [add it to a dashboard]({{< ref "adding-a-widget-to-a-dashboard.md" >}}). Parameters are automatically
discovered on the dashboard and will appear at the top of the screen.

Parameters with the same name used in different widgets use the same input field, and allow
you to change a single field and have it impact the entire dashboard.

By default the input fields are plain text fields that default to `*` - just like on the search page.
But you can customize parameters to make it easier to use and allows the user to select values in
a dropdown instead of manually typing.

## Configuring a Parameter

There are three types of parameter:

- Free Text Parameters
- Search Result Based Parameters
- Parameters with a fixed set of options

To configure a parameter, take the dashboard into "Edit Mode" by clicking the "Edit Dashboard"
button in the top menu.

![Toggle Edit Mode](/images/pages/dashboards/edit-mode.png)

You will see that parameters now look different and that there is a settings icon next to each
parameter input field. Clicking the settings icon will bring up a popup that allows you to choose options
for the parameter.

![Parameter Settings](/images/pages/dashboards/param-config.png)


### Default Value

One of the most important parameter settings is the "Default Value" field. It allows you to
set the default value the parameter should have if nothing else is specified.

In many cases this will just be `*` indicating "no filtering" but in
other cases you might want to set e.g. `production` for an `?environment` parameter.

### Query Based Parameters

Quite often you will want to filter or aggregate based on values that appear in your logs. You
can use the "Values from Search Results" parameter type for this.

This will make the parameter input into a dropdown box where the options in the dropdown is taken
from search results. Just fill in the **Query String** field with a humio query.
Usually you will want to use this in conjunction with an aggregate function like {{< function "top" >}} and find the most frequent values that appear in a certain field, e.g. you could find all hosts in your production cluster using:

```humio
env=PROD | top(host)
```

You will need to then set `host` as the value in **Dropdown Value Field**, meaning it is the value of this field
(`host`) in the search results from the query `env=PROD | top(host)` that should be bound to the parameters.

{{% notice tip %}}
Pro Tip: If the parameters options are not human readable values you can assign a **Dropdown Text Field**,
and use e.g. the {{< function "match" >}} function and a file to lookup human readable names.
{{% /notice %}}

### Fixed List Parameters

If you have a fixed set of values you would like to use for possible values to select from you can use
the "Fixed List of Values" parameter type.

## URL

When parameters are assigned they will be added to the URL and you can share a link to a dashboard configuration
simply by sharing the URL of what you are looking at.

This can also be used to integrate with other systems, where you can construct dashboard URLs that contain
parameters. This could for instance be an IP found in an external system that you want to look at logs for on
a dashboard.

Notice that URLs use the syntax `dashboards/<dashboard-id>?$param1=value1&$param2=value2` where parameters are
denoted with the `$` sign instead of the `?` (like you use in queries). This is because of `?` being a reserved
character in URLs. 

## Parameter FAQ

### Where can parameters be used in a query?

A parameter must be can only be assigned simple values, you cannot for instance assign
a [regex literal]({{< ref "language-syntax/_index.md#extracting-fields" >}}) (e.g. `/error/i`),
an array argument or a sub query (e.g. `foo AND bar`).

You can work around these restrictions by using multiple parameters or by using functions
such as {{< function "regex" >}}:

```humio
regex(?regex, field="message")
```

In this example we use a parameter to represent the string used as a regular expression that
is matched against the field message.

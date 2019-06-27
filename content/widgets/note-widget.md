---
title: The Note Widget
weight: 590
menuTitle: Notes
aliases: ["/ref/notes"]
---

Using the Note Widget you can add descriptions, instructions, links and images to your dashboards.
Notes are written in [markdown syntax](https://guides.github.com/features/mastering-markdown/) which
allows you to style the text and insert HTML snippets and create links to other dashboards and external
systems.

{{< figure src="/pages/note-widgets/note-widget.png" class="screenshot" caption="A dashboard with a note widget containing links to other pages and an image." >}}

## Example Markdown Note {#example}

```markdown
## Instructions
This dashboard contains the current status of our systems.
These links will take you to relevant external systems:

- [Grafana Dashboard using this dashboard's time range](https://play.grafana.org/d/000000012/grafana-play-home?orgId=1&from={{startTime}}&to={{endTime}})
- [Host Details Humio Dashboard](/my-repo/dashboards/19213?host={{ parameter "host" }})

Here is a kitten:
![So cute](http://www.lolcats.com/images/u/12/43/lolcatsdotcomnapkin.jpg)
```

## Templates {#templates}

As you might have noticed in the [example above]({{< ref "#example" >}}) you can
inject values into your notes using embedded template expressions. A template expression
is wrapped in `{{ ... }}` (double curly braces).

This is especially usful when used to create links to external systems, where you can
pass information from the dashboard as part of the URL.

An expression is either a variable name or a function call. Here are the
variables and functions available in template expressions. 

### Variables
<hr/>

_`startTime`_

Usage: `{{ startTime }}`

The _start_ of the current global dashboard time interval - as selected in the time selector.
It does not matter if you have activated global time or not, this will always be available.

It is formatted as a milliseconds instant, e.g. `1561584065821`.

This is very useful when if you want to use the dashboard's current time interval to look at
details in another system or dashboard.
<hr/>

_`endTime`_

Usage: `{{ endTime }}`

The _end_ of the current global dashboard time interval - as selected in the time selector.
It does not matter if you have activated global time or not, this will always be available.

It is formatted as a milliseconds instant, e.g. `1561584095932`. 

This is very useful when if you want to use the dashboard's current time interval to look at
details in another system or dashboard.
<hr/>

### Template Functions {#template-functions}

_`parameter`_

Usage: `{{ parameter "<PARAM_ID>" }}`
Example: `{{ parameter "hostname" }}`

Inserts the current value of a [dashboard parameter]({{< ref "parameters.md" >}}).



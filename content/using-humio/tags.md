---
title: Tags
---

{{% notice warning %}}
Tags are an **advanced feature**. You should see that you have performance
issues before considering adding custom tags. If not used appropriately they
can adversely impact performance and increase resource usage.
{{% /notice %}}

Humio saves data in Data Sources. You can provide a set of Tags to specify which Data Source the data is saved in.  
You can add Tags to [Events]({{< ref "events.md" >}}) that you ingest into Humio.
Tags provide an important way to speed up searching. They allow Humio to select which Data Sources to search through.     
For example, you can add Tags to Events that represent host names, file names, service names, or the kind of service.  
Tags can be configured in [parsers]({{< ref "parsing.md" >}}) or specified in the APIs for data ingestion.

In Humio tags always start with a #. When turning a field into a tag it will be
prepended with `#`.
If fields start with an `@` or `_` , the character is removed before prepending
the `#`.

## Limit the number of tags

You should use tags for the aspects that you want to search for most often.  
Do not create more distinct dynamic tags than you need. This reduces system
performance and increases resource usage.  
You should set dynamic values, such as names that include dates, as Event
attributes, not Tags. Attributes are individual key/values that are associated
with an individual Event.

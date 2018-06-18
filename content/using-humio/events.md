---
title: Events
---

Events are data items that represent a particular message, incident, or logging
item from a system. They are the most important data type in Humio.

Each Event contains a timestamp and a set of key/value attributes.

Humio represents the original text of the Event in the attribute `@rawstring`.
You can configure a parser to extract the attributes and timestamp of Events
from the raw text entries.

For JSON data, you can specify what the `@rawstring` represents. By default
this is the original JSON data string.

The timestamp of an event is represented in the `@timestamp` attribute.

Events can also have [tags]({{< ref "tags.md" >}}) associated with them.
The Data Source manages and stores tags related to events. This means that tags
do not add to the storage requirements of individual events.

Events also have a special `#repo` tag that denotes the repository the event comes from.
This is useful in cross-repository searches when using [Views]({{< ref "views.md" >}}).

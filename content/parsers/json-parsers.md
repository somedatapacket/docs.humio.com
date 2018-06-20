---
title: JSON Parsers
weight: 200
---

Humio has a special class of parser, called JSON parsers. Since
JSON data is already structured, you do not need to extract fields manually.
Humio turns JSON properties into fields as shown below:

```json
{
  "ts": "2017-02-22T11:04:17.000+01:00",  
  "loglevel": "INFO",  
  "thread": "TimerThread",  
  "timing": {  
    "name": "service1",
    "time": 42
  }
}
```

Resulting Fields:

| field      | value                           |
|------------|---------------------------------|
|ts          | "2017-02-22T11:04:17.000+01:00" |
|loglevel    | "INFO"                          |
|thread      | "TimerThread"                   |
|timing.name | "service1"                      |
|timing.time | 42                              |


The reason we sometimes need to define custom JSON parsers is to parse the timestamp.
The build-in JSON parser ([json]({{< ref "json.md" >}})) expects
a field called `@timestamp`, but this will not always exist for arbitrary JSON logs.

When defining a JSON parser you specify which JSON property should be used as timestamp,
and how that field should be parsed.

You can find out how to parse timestamps at the [Parsing Timestamps section below]({{< relref "#parsing-timestamps" >}}).


{{% notice tip %}}
***Testing***  
You can test the parser on the **Parser** page by adding some test data. This offers an interactive way to refine the parser.
See the section on [Testing the Parser]({{< relref "#testing-parsers" >}}) section below.
{{% /notice %}}

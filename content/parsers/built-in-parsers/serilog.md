---
title: serilog-jsonformatter
---

This parser can process log lines written by [Serilogs](https://serilog.net) `JsonFormatter`.

Example serilog configuration:

```csharp
 Log.Logger = new LoggerConfiguration()
                .WriteTo.File(formatter: new JsonFormatter(renderMessage: true), path:logPath, rollingInterval: RollingInterval.Day)
```

Note the required `renderMessage: true` part of the configuration. Humio will display the rendered message outputted by Serilog instead of the raw event. The parser achieves this by setting the [@display]({{< relref "concepts/events.md#metadata" >}}) field to the rendered message.


## Example Input

```
{"Timestamp":"2019-01-21T13:26:25.1354930+01:00","Level":"Information","MessageTemplate":"Processed {@Position} in {Elapsed:000} ms.","RenderedMessage":"Processed { Latitude: 25, Longitude: 134 } in 034 ms.","Properties":{"Position":{"Latitude":25,"Longitude":134},"Elapsed":34,"ProcessId":"15133"},"Renderings":{"Elapsed":[{"Format":"000","Rendering":"034"}]}}
```

Properties outputted by Serilog are available on the parsed event as e.g. `Properties.Position.Latitude` from the above example input.
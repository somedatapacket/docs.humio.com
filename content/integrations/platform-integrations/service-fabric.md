---
title: "Service Fabric"
categories: ["Integration", "Platform"]
pageImage: /integrations/sf.png
---

Humio integrates with [Azure Service Fabric](https://azure.microsoft.com/en-us/services/service-fabric/). The integration differentiates between:

1. Service Fabric [Platform Events](https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-diagnostics-events) that communicate key operational activities happening within a cluster.  

2. Applications running on a Service Fabric cluster. E.g. .NET core applications using [Serilog](https://serilog.net). 

Both types are made available for searching and analysis in Humio. 

Refer to the [detailed guide](https://github.com/humio/service-fabric-humio) for setting up an integration. The following provides a summary. 

## Platform Events

Service Fabric Platform events are available as an [Event Tracing](https://docs.microsoft.com/en-us/windows/desktop/etw/about-event-tracing) provider on Windows. As part of the integration a Windows Service using the [Eventflow library](https://github.com/Azure/diagnostics-eventflow) is made available. Properly configured the service will send platform events to Humio for further analysis.

## Application logs

The [detailed guide](https://github.com/humio/service-fabric-humio) contains a solution for configuring .NET applications with [Serilog](https://serilog.net) and Humio. Humio provides a [built-in Serilog parser](/parsers/built-in-parsers/serilog) that works together with the suggested configuration. Filebeat is used for [shipping the logs to Humio](/integrations/data-shippers/beats/filebeat).
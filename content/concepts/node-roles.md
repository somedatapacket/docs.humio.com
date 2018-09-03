---
draft: true
title: Node Roles
---

A server can be configured to assume up to three logical roles:

- Ingest Node
- Digest Node
- Storage Node

A node can have any combination of the three roles, and all three types play a
special part in the [ingest flow]({{< ref "ingest-flow.md" >}}).


## Arrival Node {#arrival-node}

An _arrival node_ is a node that is responsible for serving the UI and API request.
This includes the any of the [ingest APIs]({{ ref "ingest-api.md" }}).

The actual parsing of incoming data into events occur on arrival nodes


## Digest Node {#digest-node}


## Storage Node {#storage-node}

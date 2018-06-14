---
title: "FAQ"
weight: 7
pre: "<b>7. </b>"
---

### What happened to "Dataspaces"

"Repository" is the new term. What used to be a "dataspace" in Humio is now a [Repository]({{< relref "getting_started/repositories.md" >}}).

The HTTP API includes the path `/api/v1/dataspaces/$REPOSITORY_NAME/` to be compatible with existing clients.
In this context, the `$REPOSITORY_NAME` variable is the name of the repository. (It used to be the name of the dataspace).

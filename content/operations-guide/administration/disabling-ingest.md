---
title: "Disabling Ingest"
weight: 50
aliases: ["/administration/disabling-ingest"]
---

Humio has the ability to pause ingestion of data into a repository when needed.
This feature is found in the "Settings" portion of a repository under the name
"Block Ingest".  Reasons to consider blocking ingest include:
 * The data arriving is corrupt or otherwise causing issues
 * You'd like to prevent new data from arriving before you update the parser syntax.
 * The volume of data arriving is overwhelming your current cluster size

## Blocking Ingest

Ingest can be blocked by simply opening that repository, going into the settings
and then choosing "Block Ingest".  There you can specify how long you'd like to
prevent new events from being ingested for this repository as the "block period"
and click "Block Ingestion".  If successful you will see a notice:

```
Ingest is blocked!

Block expires at: ... datetime in the future ...
Unblock
```

## Unblocking Ingest

Clicking the unblock will re-enable ingest for that repository.  When the duration
of the block expires then ingest is re-enabled.  The maximum duration allowed is 1
year.

##

When you block ingest all sockets opened for ingest into this repository are
closed and not re-opened until the block has expired or be removed by hand.
Most log shippers will simply queue up the log records when they can't deliver
them and then when the connection is re-opened they will ship all the missing
data as well as new data from that point on.

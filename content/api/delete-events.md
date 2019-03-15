---
title: Delete Events API
---

{{% notice note %}}
Delete Events is a BETA feature.
Requires Humio version 1.5.0+
{{% /notice %}}

Humio has support for deleting individual events from the compressed
segment files. The purpose of this is to be able to get rid of data
that *must* no longer be in the log for whatever reason. An example
would be if an application by mistake had logged some secret into the
log-stream. Or a customer exercising the rights under the GDPR laws to
request all information on him/her to be deleted.

The goal of the delete-events if *not* to save space or speed up the
searches for other records after the delete has completed. It is only
here for the exceptional cases such as the above examples where a small
fraction of the events must be deleted for legal or technical reasons.

The delete mechanism rewrites the relevant parts of the segment files
to wipe out the actual records of the events. This is a non-trivial
operation that can spend a lot of CPU time if the number of relevant
segments is large.

The user must be authorized to execute "delete events".

This is an example using the REST API deleting all events with a password field in the specified time interval in milliseconds.
```
curl -v https://cloud.humio.com/api/v1/dataspaces/$REPOSITORY_NAME/deleteevents \
  -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"queryString": "password=*", "startTime": 1551074900671, "endTime": 1551123730700}'
```

The endpoint will return HTTP status code 201 (`Created`) if the
delete was scheduled. The entity returned is a short string being the
internal ID of the delete. You may use this if tracking the execution
of the delete in some other system.

The Graphql mutation is `deleteEvents`, and the list of pending
deletes being processed in the background is available under that name
as well.



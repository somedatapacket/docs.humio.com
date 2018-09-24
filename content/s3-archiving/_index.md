---
title: "S3 Archiving"
weight: 200
category_title: "Overview"
aliases: ["ref/s3"]
---

Humio supports archiving ingested logs to [Amazon S3](https://aws.amazon.com/s3/). The archived logs are then available for further processing in any external system that integrate with S3.

Archiving works by running a periodic job inside all Humio nodes which looks for new unarchived segment files. The segment files are read from disk, streamed to a S3 bucket and marked as archived. Enabling Humio to write to a S3 bucket means setting up AWS cross-account access. Follow these steps:

1. Log into the AWS console and navigate to the S3 service page.
2. Click on the name of the bucket where archived logs should be written.
3. Click on Permissions.
4. Click Add User.
5. Enter the canonical ID for Humio( f2631ff87719416ac74f8d9d9a88b3e3b67dc4e7b1108902199dea13da892780 ) and check the Object Access Read and Write permission check boxes and click Save.
6. In Humio go to the repository you want to archive and select S3 Archiving under Settings. Configure by giving bucket name, region etc. and Save.

The default archiving format is [NDJSON](http://ndjson.org) and optionally raw log lines.




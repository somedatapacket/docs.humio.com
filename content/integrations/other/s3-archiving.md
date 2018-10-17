---
title: "S3 Archiving"
categories: ["Integration", "OtherIntegration"]
pageImage: /integrations/aws-s3.svg
---

Humio supports archiving ingested logs to [Amazon S3](https://aws.amazon.com/s3/). The archived logs are then available for further processing in any external system that integrate with S3.

Archiving works by running a periodic job inside all Humio nodes which looks for new unarchived segment files. The segment files are read from disk, streamed to a S3 bucket and marked as archived in Humio.

An admin user needs to setup archiving per repository. After selecting a repository on the Humio front page the configuration page is available under Settings.

## S3 Layout

When uploading a segment file Humio creates the S3 object key based on the tags, start date and repository name of the segment file. The resulting object key makes the archived data browseable through the S3 management console.

The following pattern is used:

`REPOSITORY/YEAR/MONTH/DAY/TAG_KEY_1/TAG_VALUE_1/../TAG_KEY_N/TAG_VALUE_N/START_TIME-SEGMENT_ID.gz`

Read more about [Tags]({{< relref "concepts/tags.md" >}}).

## Format

The default archiving format is [NDJSON](http://ndjson.org) and optionally raw log lines. When using NDJSON the parsed fields will be available along with the raw log line. This incurs some extra storage cost compared to using raw log lines but gives the benefit of ease of use when processing the logs in an external system.

## On-premise Setup

For an on-premise installation of Humio the following configuration is neccesary:

```shell
S3_ARCHIVING_ACCESSKEY=$ACCESS_KEY
S3_ARCHIVING_SECRETKEY=$SECRET_KEY
```

The keys are used for authenticating against the S3 service. In other words the authenticated principal needs to have write access to the S3 buckets involved in the archiving. For guidance on how to retrieve S3 access keys see [AWS access keys](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys).


## Cloud Setup

Enabling Humio Cloud to write to your S3 bucket means setting up AWS cross-account access. Follow these steps:

1. Log into the AWS console and navigate to the S3 service page.
2. Click on the name of the bucket where archived logs should be written.
3. Click on Permissions.
4. Click Add User.
5. Enter the canonical ID for Humio( `f2631ff87719416ac74f8d9d9a88b3e3b67dc4e7b1108902199dea13da892780` ) and check the Object Access Read and Write permission check boxes and click Save.
6. In Humio go to the repository you want to archive and select S3 Archiving under Settings. Configure by giving bucket name, region etc. and Save.

## Tag Grouping

If tag grouping is defined for a repository the segment files will by split by each unique combination of tags present in a file. This results in a file in S3 per each unique combination of tags. The same layout pattern is used as in the normal case. The reason for doing this is to make it easier for a human operator to determine whether a log file is relevant.

{{% notice note %}}
S3 archiving is only available in version >= 1.1.27.
{{% /notice %}}




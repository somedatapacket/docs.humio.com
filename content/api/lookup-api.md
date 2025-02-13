---
title: Lookup API
---

### Files

You can use this endpoint to upload files that can be used by the
{{% function "lookup" %}} and {{% function "match" %}} functions.

You can upload files in CSV or JSON format.

{{% notice note %}}
Upload files as multipart form data.
The file should be in a part named `file`.
{{% /notice %}}


Files can be uploaded to a repository or files can be uploaded as shared files that are available in all repositories.
Shared files are visible in all repositories and can be used by all users. Only root users can upload, delete and edit shared files.
shared files are referenced from functions like {{% function "lookup" %}} and {{% function "match" %}}, by filename preprended with `/shared/`. For example `/shared/myfile.csv`

#### Example using curl to upload a file to a repository

Replace `myfile.csv` with the path to your file.

``` shell
curl https://cloud.humio.com/api/v1/repositories/$REPOSITORY_NAME/files \
 -H "Authorization: Bearer $API_TOKEN" \
 -F "file=@myfile.csv"
```

#### Example using curl to upload a shared file available in all repositories
``` shell
curl https://cloud.humio.com/api/v1/uploadedfiles/shared \
-H "Authorization: Bearer $API_TOKEN" \
-F "file=@myfile.csv"
```

The file can be deleted using:
``` shell
curl -X DELETE https://cloud.humio.com/api/v1/uploadedfiles/shared/myfile.csv \
-H "Authorization: Bearer $API_TOKEN"
```


#### Example contents for a file in CSV format.
Whitespace gets included in the keys and values. To include the separator `","` in a value, quote using the `"` character.

```
userid,name
1,chr
2,krab
"4","p,m"
7,mgr
```

#### Example contents for a file en JSON format using an object as root of the file.
In this variant, the key field does not have a name.
```json
{
 "1": { "name": "chr" },
 "2": { "name": "krab" },
 "4": { "name": "pmm" },
 "7": { "name": "mgr" }
}
```

#### Example contents for a file en JSON format using an array as root of the file.
In this variant, you select which field is the "key" using the "on" parameter in "lookup".
```json
[
 { "userid": "1", "name": "chr" },
 { "userid": "2", "name": "krab" },
 { "userid": "4", "name": "pmm" },
 { "userid": "7", "name": "mgr" }
]
```

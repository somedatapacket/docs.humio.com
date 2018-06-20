---
menuTitle: Python
title: "Python API Client"
---

If you are using python in your project take a look at our python library:

https://github.com/humio/python-humio

It supports basic operations like:

- User Management
- Data Ingestion
- Making Queries

**Example Usage**

```python
from humio_api.humio_api import HumioApi

# Init the API
h = HumioApi(baseUrl='https://cloud.humio.com', dataspace='<REPOSITORY_NAME>',
             token='<YOUR_API_TOKEN>')

# some test data
testData=[
    {
        "tags": {
            "host": "server1",
            "source": "application.log"
        },
        "events": [
            {
                "timestamp": "2016-06-06T12:00:00+02:00",
                "attributes": {
                    "key1": "value1",
                    "key2": "value2"
                }
            },
            {
                "timestamp": "2016-06-06T12:00:01+02:00",
                "attributes": {
                    "key1": "value1"
                }
            }
        ]
    }
]

# Ingesting the data
h.ingestJsonData(testData)
```

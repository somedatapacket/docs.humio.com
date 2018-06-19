---
menuTitle: Python
title: "Python library for Humio"
---

If you are using python in your project take a look at out python library:
[python-humio](https://github.com/humio/python-humio)

It supports basic operations with Humio like:

- User management
- Data ingestion
- Making Queries

**Using library example**

```python
from humio_api.humio_api import HumioApi

# Init the API
h = HumioApi(baseUrl='https://cloud.humio.com', dataspace='<YOUR_DATASPACE>',
             token='<YOUR_TOKEN>')

# some test data
jsonDt=[
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
h.ingestJsonData(jsonDt)

# see https://github.com/humio/python-humio for more
```

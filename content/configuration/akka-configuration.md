---
title: "Akka configuration"
---

Humio uses [Akka](https://akka.io/) internally. It is possible to configure Akka properties. This page describe how.

{{% notice tip %}}
The standard Humio configuration is set as described in [Configuration]({{< ref "configuration/_index.md" >}}). 
Changing Akka configuration is for more advanced use cases. 
{{% /notice %}} 


Akka configuration is specified using a [configuration file](https://doc.akka.io/docs/akka/current/general/configuration.html).  
Reference configurations are:

* [Akka](https://doc.akka.io/docs/akka/current/general/configuration.html#listing-of-the-reference-configuration)
* [Akka-HTTP](https://doc.akka.io/docs/akka-http/current/configuration.html)


To extend the default Humio configuration, a new file must be created. The new file should include Humios default Akka configuration file by beginning with the line `include "application"`.

Next the configuration file must be mounted into the Humio docker image (if you are using docker):

```
docker run ... -v $HOST_PATH_TO_FILE:/humio-akka-application.conf
```

Then tell Humio to read the new Akka configuration file. This is done using [humio-config.env]({{< ref "configuration/_index.md" >}})

```
HUMIO_JVM_ARGS= ... -Dconfig.file=/humio-akka-application.conf
``` 

The `-Dconfig.file` option is added to the JVM arguments telling Akka where to look for the configuration file.
   

The above steps should enable the new configuration when starting Humio. 
For better debugging it is possible to add `akka.log-config-on-start = "on"` to the configuration file. That will print the configuration at startup
 

## Example

In this example we want to change the Akka log level. 

``` SAML
include "application"
akka.log-config-on-start = "on"
akka.loglevel = "DEBUG"

```

---
title: bro-json
aliases: ["/parsers/built-in-parsers/bro-json"]
---

This parser can process JSON data generated from [Bro](https://www.bro.org/).  
We have documentation describing [how to send Bro data to Humio]({{< ref "bro.md" >}}).
This parser is tailored to handle the output generated from the Bro script in the linked to documentation.    
The name of the Bro log file will become a `#path` tag in Humio.

---
title: Assigning Parsers to API Tokens
---

When you send data to Humio you must specify which repository to store the data
in and which parser to use for ingesting the data. The best way of doing this is
to assign a specific parser to the Ingest API Token used to authenticate the client.

To change the assigned parser in the UI go to the parser you wish to assign.
Then go to `Settings` -> `API Tokens` and click assign on the token that is used
by the clients in question.

Assigning a parser to the API Token is the recommended way of specifying the parser to use for ingest
since it allows you to change parser in Humio without changing the client.  


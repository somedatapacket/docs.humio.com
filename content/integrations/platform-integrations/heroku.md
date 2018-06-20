---
title: "Heroku"
categories: ["Integration"]
pageImage: /integrations/heroku.svg
---

To get logs from Heroku, you need to follow the guide lines to set up a
[HTTPS Drain](https://devcenter.heroku.com/articles/log-drains#https-drains).

First you need to make sure you have a repository ready to send your logs to.
Either create a dedicated repository or if you are on a Free Humio Cloud account
use your [Sandbox Repository]({{< ref "the-sandbox.md" >}}).


The command to set up logging for your Heroku app is then:

```shell
heroku drains:add https://$INGEST_TOKEN@$HOST/api/v1/dataspaces/$REPOSITORY_NAME/logplex -a myapp
```

{{< partial "common-rest-params.html" >}}

## Extra: Parsing Heroku Logs

You can configure a parser to deal with the contents of your specific logs.
In the example below, the logplex ingester only deals with the log up to the `-` in the middle.
Anything after that is specific to the particular kind of log.

```
<40>1 2012-11-30T06:45:29+00:00 host app web.3 - State changed from starting to up
<40>1 2012-11-30T06:45:26+00:00 host app web.3 - Starting process with command `bundle exec rackup config.ru -p 24405`
```

To deal with this, you can define a parser with the name of the application and the process (sans the `.3`) `"heroku_${app}_${process}"` (in this case `heroku_app_web`).    If such a parser exists in the repository, then it will be used to do further data extration in the log's message.

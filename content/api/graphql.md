---
title: GraphQL
weight: 2
---

Humio has chosen GraphQL for our main API because it offers significantly
more flexibility for API clients. GraphQL allows you to precisely specify the
data you require, which allows you to call a single endpoint to get everything
you need. This makes creating integrations and clients for Humio much easier.

The GraphQL API is documented by our interactive API explorer:

- https://cloud.humio.com/docs/api-explorer _(Requires a [Humio Cloud Account](https://cloud.humio.com/))_  
- $BASEURL/docs/api-explorer _(Where `$BASEURL` is the hostname for on-prem install)

## New to GraphQL?

If you are unfamiliar with GraphQL don't fret. You don't need any special GraphQL
tools to use it. GraphQL is based on HTTP, and all you need is `curl` to send
requests and responses are returned as JSON.

Industry leaders like:

- GitHub
- Facebook
- Twitter

have all based their newest APIs on GraphQL.

### Resources for Learning GraphQL

- [Github's Intro to GraphQL](https://developer.github.com/v4/guides/intro-to-graphql/)
- [GraphQL.org Intro to GraphQL](https://graphql.org/learn/)
- [HowToGraphQL](https://www.howtographql.com/)

## API Explorer {#api-explorer}

Humio has a built-in API explorer bundled with each installation. You can find
it under:

`http://$HOST:$PORT/docs/api-explorer`

There newest version is always available under:

- https://cloud.humio.com/docs/api-explorer _(Requires a [Humio Cloud Account](https://cloud.humio.com/))_
- $BASEURL/docs/api-explorer (for on premise installations)

## Examples

These examples are geared toward on-prem customers and assume they're being
executed from a Humio server. You can also run them against the public Humio
hostname using an actual user API token (which is obtained from the "Your Account"
area from the menu on the right in the header). This is being done for simplicity's
sake and the fact that it will work on any installation if executed from the
server running Humio.


**List Users**
```
curl -v -XPOST -H "Content-Type: application/json" \
  -H "Authorization: bearer $(cat /data/humio-data/local-admin-token.txt)" \
  http://127.0.0.1:8080/graphql \
  -d '{ "query": "{ accounts { username } }" }'
```

**Add User**
```
curl -v -XPOST -H "Content-Type: application/json" \
  -H "Authorization: bearer $(cat /data/humio-data/local-admin-token.txt)" \
  http://127.0.0.1:8080/graphql \
  -d '{ "query": "mutation { addUser(input: { username: \"user@example.com\" }) { user { id } } }" }'
```

**Remove User**
```
curl -v -XPOST -H "Content-Type: application/json" \
  -H "Authorization: bearer $(cat /data/humio-data/local-admin-token.txt)" \
  http://127.0.0.1:8080/graphql \
  -d '{ "query": "mutation { removeUser(input: { username: \"user@example.com\" }) { clientMutationId } }" }'
```

**Add User to Repository**
```
curl -v -XPOST -H "Content-Type: application/json" \
  -H "Authorization: bearer $(cat /data/humio-data/local-admin-token.txt)" \
  http://127.0.0.1:8080/graphql \
  -d '{ "query": "mutation { addMember(searchDomainName: \"your-repo-name-here\", username: \"user@example.com\", hasMembershipAdminRights:false, hasDeletionRights:false)  { clientMutationId } }" }'
```

## Why use both GraphQL and REST?

Some resources in Humio must be accessed with REST. This is both for of historical
reasons and that we feel that REST is better suited for our Querying API.
Also HTTP streaming is more appropriate for our streaming results, though we may
add support for GraphQL Subscriptions the future.

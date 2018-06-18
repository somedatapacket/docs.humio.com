---
title: GraphQL
weight: 2
---

Humio has chosen GraphQL for our main API because it offers significantly
more flexibility for API clients. GraphQL allows you to precisely specify the
data you require, which allows you to call a single endpoint to get everything
you need. This makes creating integrations and clients for Humio much easier.

## New to GraphQL?

If you are unfamiliar with GraphQL don't fret. You don't need GraphQL special
tools to use it. GraphQL is based on HTTP, and all you need is `curl` to send
requests and returns JSON responses.

Industry leaders like:

- Github
- Facebook
- Twitter

have all based their newest APIs on GraphQL.

### Resources for Learning GraphQL

- [Github's Intro to GraphQL](https://developer.github.com/v4/guides/intro-to-graphql/)
- [GraphQL.org Intro to GraphQL](https://graphql.org/learn/)
- [HowToGraphQL](https://www.howtographql.com/)

## API Explorer

Humio has an built-in API explorer bundled with each installation. You can find
it under:

`http://$HOST:$PORT/docs/api-explorer`

There newest version is always available under:

`https://cloud.humio.com/docs/api-explorer`

<!-- TODO: Remove once redirect is implemented for the api-explorer -->
Make sure to log in to your account before visiting the API Explorer.

## Why use both GraphQL and REST?

Some resources in Humio must be accessed with REST. This is both for of historical
reasons and that we feel that REST is better suited for our Querying API.
Also HTTP streaming is more appropriate for our streaming results, though we may
add support for GraphQL Subscriptions the future.

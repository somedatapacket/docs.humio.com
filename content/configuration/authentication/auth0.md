---
title: Authenticating with Auth0
menuTitle: Auth0
pageImage: /integrations/auth0.svg
---

Humio can be configured to authenticate users through [Auth0](https://auth0.com/). Unless you have specific requirements,
Auth0's free tier is sufficient.

You can choose which Identity Providers (e.g. Google, Github and Facebook) you wish to allow for authentication.

{{% notice info %}}
__GDPR Consideration__  
Auth0 keeps information about your users. This may require you to have a Data Processing Agreement with
Auth0. If all you need is Google and GitHub, you can use [Humio's build-in support for these providers]({{< ref "oauth.md" >}}) and
avoid storing your users' personal data with a third party provider.
{{% /notice %}}

## Create a Humio Application

You should create an Auth0 Application specifically for Humio.
When selecting the type of application you should choose the option _Regular Web Application_.

Once the application is created you will need to set up a couple of properties.

## Find your Application's Configuration

Under the application's _Settings_ page find:

- _Client ID_
- _Client Secret_
- _Domain_

We will need these for Humio's settings, you will also have to set the
`AUTHENTICATION_METHOD` option to `auth0`, e.g.:

```shell
AUTHENTICATION_METHOD=auth0
AUTH0_CLIENT_ID=$YOUR_CLIENT_ID
AUTH0_CLIENT_SECRET=$YOUR_CLIENT_SECRET
AUTH0_DOMAIN=$YOUR_AUTH0_DOMAIN
PUBLIC_URL=$YOUR_SERVERS_BASE_URL
```

_See the [installation overview page](/operation/installation) on how to set
these settings for your Humio cluster._

## Setting the Callback URI

In order to avoid CSRF attacks you must set the _Allowed Callback URLs_ field
to `%PUBLIC_URL%/auth/auth0`, e.g. https://www.example.com/auth/auth0, where
`%PUBLIC_URL%` is the value of the Humio configuration option `PUBLIC_URL`.

_Using Auth0 authentication for Humio requires that you set the `PUBLIC_URL` configuration option.

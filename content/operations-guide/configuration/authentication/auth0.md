---
title: Authenticating with Auth0
menuTitle: Auth0
pageImage: /integrations/auth0.svg
aliases: ["/configuration/authentication/auth0"]
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

_See the [configuration overview page]({{< ref "/configuration/_index.md" >}}) on how to set
these settings for your Humio cluster._

## Setting the Callback URI

In order to avoid CSRF attacks you must set the _Allowed Callback URLs_ field
to `%PUBLIC_URL%/auth/auth0`, e.g. https://www.example.com/auth/auth0, where
`%PUBLIC_URL%` is the value of the Humio configuration option `PUBLIC_URL`.

Using Auth0 authentication for Humio requires that you set the `PUBLIC_URL` configuration option.

## Mapping Auth0 Roles

Using the _Auth0 Authorization Extension_ you can define Auth0 roles and have them mapped to Humio groups.

> Note: The users/roles defined at top-level in the Auth0 dashboard do not work with this.  This only works for users/roles defined inside the _Auth0 Authroization Extension_, which is found in the left side _Extensions_ menu item.

The _Auth0 Authorization Extension_  requires an _Auth0 Rule_ of its own installed to work, and additionally you need to create a rule to copy the roles into the token returned by Auth0 to Humio.  This additional rule could look like this:

```
// rule to copy user's roles into the returned token
function (user, context, callback) {
  context.idToken["https://auth0-example.humio.com/roles"] = user.roles;
  callback(null, user, context);
}
```

The attribute `https://auth0-example.humio.com/roles` in this example is the user-configurable attribute that will hold the Auth0 roles.  If you configure `AUTH0_ROLES_KEY=https://auth0-example.humio.com/roles` (in Humio) and add the above _Auth0 Rule_ in the Auth0 dashboard, the the assighed roles are transferred to humio in the AWT token and are made available to humio.

There are several way to apply these Auth0 roles in humio.

- Create roles in Auth0 named `view.member`, `view.admin`, where `view` is the name of an actual view or repo in Humio, which will allow users to be member or admins in Humio.  For instance, if a user is added to `humio.member`, then she can see the contents of the `humio` repository.
- Alternatively (if more detailed permissions are desired),  Group/repo appings can be [defined in a separate file]({{< ref "role-based-auth.md#setting-up-authorization-rules-from-a-file" >}}).

Either way, it usually makes sense to also define these options in humio as also [described on this page]({{< ref "role-based-auth.md" >}}).  IF `AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN` is not set, then users must already have been created before hand inside Humio's UI.  

```
AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN=true
AUTO_UPDATE_GROUP_MEMBERSHIPS_ON_SUCCESSFUL_LOGIN=true
```

The property `AUTO_UPDATE_GROUP_MEMBERSHIPS_ON_SUCCESSFUL_LOGIN` controls that group membershi rules in Humio are transferred upon login.  

> When deleting a user in Auth0 and/or changing access rights in Auth0, those are not reflected until the user logs into Humio again.

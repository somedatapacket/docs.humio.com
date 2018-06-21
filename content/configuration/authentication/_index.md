---
title: Authentication
category_title: Overview
aliases: ["operation/installation/authentication"]
---

Humio supports the following authentication types:

* __None__ (Default)
   Humio can run without authentication at all, and with only a single user account named _developer_.
   This is the default if authentication is not configured, but is __not recommended__ for production systems.
* [__Single user__]({{< ref "single-user.md" >}})  
   Single-user mode is similar to running with no authentication except that it enables login using a password.
* [__LDAP__]({{< ref "ldap.md" >}})  
   Humio can connect to an LDAP server and authenticate users
* [__By-Proxy__]({{< ref "auth-by-proxy.md" >}})  
   Humio can use the username provided by the proxy in a HTTP header.
* [__OAuth2 Identity Providers__]({{< ref "oauth.md" >}}")  
   Authentication is done by external OAuth identity provider, Humio supports:
   - [Google]({{< ref "oauth.md#google" >}})
   - [GitHub]({{< ref "oauth.md#github" >}})
   - [BitBucket]({{< ref "oauth.md#bitbucket" >}})
* [__Auth0 Integration__]({{< ref "auth0.md" >}})  
  [Auth0](https://auth0.com/) is a cloud service making it possible to login with many different OAuth identity providers e.g. Google and Facebook. You can also create your own database of users in Auth0.

Users are authenticated (logged in) using one of the above integrations.
But the authorization is done in Humio.
Which repositories a user can access is specified in Humio.


{{% notice warning %}}
__Authentication disabled by default__  
In order to make first-time setup easy for new users, Humio defaults to running without authentication
at all. This is __not recommended__ for production environments.
{{% /notice %}}

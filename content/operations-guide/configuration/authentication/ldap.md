---
menuTitle: LDAP
title: Authenticating with LDAP
pageImage: /integrations/ldap.svg
aliases: ["/configuration/authentication/ldap"]
---

It is possible to authenticate and fetch group membership from an LDAP server.  LDAP, although
a standard, is highly configurable and not always deployed in the same manner in organizations.
Humio provides two ways to authenticate using LDAP.

 * `ldap` is the more common method and should be tried first.
 * `ldap-search` is useful when the user authenticating with Humio can't search within the LDAP directory service. 
 
## Prerequisites

Before configuring LDAP you need to ensure that a root account exists on the system. You can do this either by adding
the user name (the full name including domain name) via the
[administration section]({{<ref "../../configuration/basic-configuration/user-authentication.md">}}), or by the
API: [root access]({{<ref "../../configuration/basic-configuration/root-access.md">}}).

## Configuration File Location

Humio can be run within Docker or as any other application.  When we refer to setting environment variables below you'll
either be editing a file in `/etc/humio` directory and restarting the server or changing the content of the file you
provided to the `--env-file=` parameter when launching docker.

The file in `/etc/humio` is named `server.conf` or `server_all.conf` if you are not on a multi-socket
NUMA system and running one JVM per CPU socket

For simplicity we'll assume below that you are using docker and have named your configuration file `humio-config.env`
adjust accordingly.

## LDAP

When the user name and password you'd like to use with Humio is one that can login to and search the LDAP
(or Active Directory) service then this method is likely to be the right one to configure.

Set the following parameters in `humio-config.env`:

```shell
AUTHENTICATION_METHOD=ldap
LDAP_AUTH_PROVIDER_URL=your-url             # example: ldap://ldap.forumsys.com:389
LDAP_AUTH_PRINCIPAL=your-principal          # optional, example: cn=HUMIOUSERNAME,dc=example,dc=com
LDAP_DOMAIN_NAME=your-domain.com            # optional, example: example.com
AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN=true   # default is false 
```

`AUTHENTICATION_METHOD=ldap` enables this more standard LDAP bind method.

`LDAP_AUTH_PROVIDER_URL` is the URL to connect to. It can start with either `ldap://` or `ldaps://`, which selects
unencrypted or TLS/SSL transport respectively.  We recommend using a secure connection to ensure that authentication
credentials are not transmitted in the clear.

`LDAP_AUTH_PRINCIPAL` is optional.  We provide this so that you can transform the username provided to Humio during
login (e.g. `john@example.com` is the HUMIOUSERNAME `john`) into something that your LDAP server will authenticate.
To do this you simply supply a pattern and include the special token `HUMIOUSERNAME` which we will replace with the
username provided at login before attempting to bind to the LDAP server.  This is how you can specify the principal
provided to your LDAP server.  So, if you provide `cn=HUMIOUSERNAME,dc=example,dc=com` and attempt to login to Humio
with the username of `john@example.com` we will bind using a principal name `cn=john,dc=example,dc=com` and the
password provided at the login prompt.  If you have users in more than one location within LDAP you can separate the
multiple patterns and Humio will try to authenticate in order the options you've provided.  Split the value set in
`LDAP_AUTH_PRINCIPAL` using `LDAP_AUTH_PRINCIPALS_REGEX` pattern.  This doesn't apply when using the `ldap-search`
method.
```bash
LDAP_AUTH_PRINCIPALS_REGEX=';'
LDAP_AUTH_PRINCIPAL='cn=HUMIOUSERNAME,dc=example,dc=com;cn=HUMIOUSERNAME,dc=foo,dc=com;cn=HUMIOUSERNAME,dc=bar,dc=com'
```

`LDAP_DOMAIN_NAME` can be used if your directory service is only hosting single domain (e.g. `example.com`) and you'd
like to allow your users to login to Humio with their username and not domain name (e.g. `john` rather than
`john@example.com`) then set this to the common domain name for all users (e.g. `example.com` in this case).
While this makes use of the domain name optional it is still allowable to add the domain when logging in as long as
it matches.

`AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN` (default is `false`) when `true` will create new users in Humio on successful
login if that user didn't already exist.  Otherwise only manually added users who can authenticate with LDAP will be
allowed to login to Humio.

## LDAP-search (using a bind user)

If LDAP/AD requires login with the exact DN, then it is possible to first do a search for the DN using
a low-privileged bind username, and then successively do the login with the discovered DN.  Put a different way,
when you configure Humio to use the `ldap-search` method it then uses a bind user you supply to search for the
given user's DN and then that DN is used to authenticate and discover group membership.  Config settings prefixed
with `LDAP_SEARCH_...` are used to in the first stage to login and search for the DN for a given user.

To enable this, use this alternative property set:

```shell
AUTHENTICATION_METHOD=ldap-search
LDAP_AUTH_PROVIDER_URL=your-url             # example: ldap://ldap.forumsys.com:389
LDAP_DOMAIN_NAME=your-domain                # example: example.com
LDAP_SEARCH_BASE_DN=search-prefix           # example: ou=DevOps,dc=example,dc=com
LDAP_SEARCH_BIND_NAME=bind-principal        # example: cn=Bind User,dc=example,dc=com
LDAP_SEARCH_BIND_PASSWORD=bind-password     # the password for the LDAP_SEARCH_BIND_NAME
LDAP_SEARCH_FILTER=custom-search-filter     # optional, example: (& (userPrincipalName={0})(objectCategory=user))
AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN=true   # default is false
```

If set `LDAP_SEARCH_FILTER` is used when searching the directory server for a DN in the subtree specified by
`LDAP_SEARCH_BASE_DN`, using the bind-principal/password, providing what a user entered at the login prompt as
parameter to search.  The special `{0}` component of the filter is replaced with the principal name before the filter
is used to perform the search.

If `LDAP_SEARCH_FILTER` is not set, these two default filters are tried in the following order.  Most LDAP compliant
directory servers will work with one of these two filters.
```
"(& (userPrincipalName={0})(objectCategory=user))"
"(& (sAMAccountName={0})(objectCategory=user))"
```

Put another way, Humio will attempt the two searches above within the directory server, first it will
search for:

 * `(& (userPrincipalName=john@example.com)(objectCategory=user))`
 * `(& (sAMAccountName=john)(objectCategory=user))`

assuming the username provided to Humio at login was `john@example.com`.  Both searches are restricted to the subtree
specified by the value of `LDAP_SEARCH_BASE_DN` and will use the bind-principal and password provided to Humio at login.

If either of those searches returns a "distinguishedName", then that DN is used to login (bind) with the end-user
provided password.  A search for `(& (dn={0})(objectCategory=user))` is then performed in the new context, with the`{0}`
replaced with the DN found as further validation of that context.

## How to Configure LDAP to use TLS/SSL

If you are enabling TLS/SSL secured communications to the LDAP server (e.g. when you configure the provider URL
with `ldaps:`) some TLS negotiations will require that you provide a certificate in the key exchange process.  To
do that with Humio you'll need to specify `LDAP_AUTH_PROVIDER_CERT` to be the PEM-format value of the certificate.

There is one further complication when using docker.  Docker does not support newlines in environment variables.  The
workaround is to replace newlines with `\n`.  Here is an example using the `sed` command to do the translation, you
 can of course use other tools as well.

```shell
cat my.crt | sed -e 's/\n/\\n/g'
```

If before the command the certificate looked like this:

```
-----BEGIN CERTIFICATE-----
MII...gWc=
-----END CERTIFICATE-----
```

Then after running this command it will be reformatted to look like this:

```
-----BEGIN CERTIFICATE-----\nMII...gWc=\n-----END CERTIFICATE-----\n
```

And then within the `humio-config.env` file it will be a single line like this:

```properties
LDAP_AUTH_PROVIDER_CERT=-----BEGIN CERTIFICATE-----\nMII...gWc=\n-----END CERTIFICATE-----\n
```
Note that it should be one line containing `\n` where there were newlines before and that it *must* end in `\n`
(and not `%` which is often added by the shell).

If you are using docker and choose not to provide this config parameter trust is established using the docker
container's regular CA authority infrastructure.


## LDAP Configuration Help

LDAP can be tricky, we have a tool available upon request that can make it easier to test the values required to use
Humio outside of running Humio itself and with more detailed and helpful messages.  Join the MeetHumio Slack and reach
out for help and we'll provide that tool to you and get your configuration working.

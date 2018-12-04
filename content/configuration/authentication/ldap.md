---
menuTitle: LDAP
title: Authenticating with LDAP
pageImage: /integrations/ldap.svg
---

We have 2 ways to authenticate using LDAP. `ldap` which checks that a
user can bind to the LDAP server and `ldap-search` which uses a bind
user to search for the given user.

## Prerequisites

Before configuring LDAP you need to ensure that a root account exists
on the system. You can do this either by adding the user name (the
full name including domain name) via the [administration
section]({{<ref "/configuration/user-management.md">}}), or by the
API: [root access]({{<ref "/configuration/root-access.md">}}).


## LDAP

It is possible to check the password of your users using an ldap server,
such as an AD. Set the following parameters in `humio-config.env`:

```shell
AUTHENTICATION_METHOD=ldap
LDAP_AUTH_PROVIDER_URL=your-url             # (example: ldap://ldap.forumsys.com:389)
LDAP_AUTH_PRINCIPAL=your-principal          # optional (example: cn=HUMIOUSERNAME,dc=example,dc=com)
LDAP_DOMAIN_NAME=your-domain.com            # optional (example: example.com)
AUTO_CREATE_USER_ON_SUCCESSFULL_LOGIN=true  # default is false 
```

`AUTHENTICATION_METHOD=ldap` turns on "simple" ldap checking using an ldap bind.

`LDAP_AUTH_PROVIDER_URL` is the URL to connect to. It can start with either
`ldap://` or `ldaps://`, which selects plain and SSL connections respectively.

`LDAP_AUTH_PRINCIPAL` can be left unset, in which case the username is used directly when binding to the server.
If it is set, the token `HUMIOUSERNAME` is replaced with the username entered in the login prompt, and the resulting string is used as principal.

`LDAP_DOMAIN_NAME` can be used if your ldap is only hosting 1 domain. When setting this, users do not need to provide the domain. They can login with `foo` instead of `foo@example.com`. It is always possible to add the domain when logging in.

`AUTO_CREATE_USER_ON_SUCCESSFULL_LOGIN` if false - which is the default, users must be created in Humio before they can login. If set to true, users are auto created if they login successfully 


The URL can be `ldap:/` or `ldaps:/`.  If using `ldaps:/`, you can configure Humio to work with the a server
using a self-signed certificate by specifying `LDAP_AUTH_PROVIDER_CERT` to be the PEM-format value of the certificate.  If this config parameter is not specified, trust is established using the docker container's regular ca authority infrastructure.

Since docker does not support newlines i environment variables, replace newlines with `\n` using something like this:

```shell
cat my.crt | sed -e 's/\n/\\n/g'
```

The result should look like this:

```
-----BEGIN CERTIFICATE-----\nMII...gWc=\n-----END CERTIFICATE-----\n
```

Add the above to the humio-config.env file like this

```properties
LDAP_AUTH_PROVIDER_CERT=-----BEGIN CERTIFICATE-----\nMII...gWc=\n-----END CERTIFICATE-----\n
```
It should be one line containing \n. It must end in \n (and not % which is often added by the shell)

## LDAP-search (using a bind user)

If LDAP/AD requires login with the exact DN, then it is possible to first do a search for the DN using
a low-priviledge bind username, and then successively do the login with the correct DN.  
To enable this, use this alternative property set:

```shell
AUTHENTICATION_METHOD=ldap-search
LDAP_AUTH_PROVIDER_URL=your-url             # (example: ldap://ldap.forumsys.com:389)
LDAP_DOMAIN_NAME=your-domain                # (example: example.com)
LDAP_SEARCH_BASE_DN=search-prefix           # (example: ou=DevOps,dc=example,dc=com)
LDAP_SEARCH_BIND_NAME=bind-principal        # (example: cn=Bind User,dc=example,dc=com)
LDAP_SEARCH_BIND_PASSWORD=bind-password
LDAP_SEARCH_FILTER=custom-search-filter     # (Optional, example: (uid={0}))
AUTO_CREATE_USER_ON_SUCCESSFULL_LOGIN=true  # default is false
```

If `LDAP_SEARCH_FILTER` is set, Humio makes a search for a DN matching the provided filter
in the subtree specified by `LDAP_SEARCH_BASE_DN`, Using the bind-principal/password,
providing what a user entered at the login prompt as parameter to search.

If `LDAP_SEARCH_FILTER` is not set, the default filters to use are the following.
```
"(& (userPrincipalName={0})(objectCategory=user))"
"(& (sAMAccountName={0})(objectCategory=user))"
```

Humio will make the two searches above, one on `sAMAccountName=%HUMIOUSERNAME%`,
and one on `userPrincipalName=%HUMIOUSERNAME%@%LDAP_DOMAIN_NAME%` in the subtree specified by `LDAP_SEARCH_BASE_DN`,
using the bind-principal/password. Here `%HUMIOUSERNAME%` is what the user entered at the login prompt.


If either of those searches returns a "distinguishedName", then
that DN is used to login (bind) with the end-user provided password.
A search for `(& (dn={0})(objectCategory=user))` is then performed in the new context,
with the DN found as further validation of that context.

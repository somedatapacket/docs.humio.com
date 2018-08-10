---
menuTitle: LDAP
title: Authenticating with LDAP
pageImage: /integrations/ldap.svg
---

It is possible to check the password of your users using an ldap server,
such as an AD. Set the following parameters in `humio-config.env`:

```shell
AUTHENTICATION_METHOD=ldap
LDAP_AUTH_PROVIDER_URL=your-url      # (example: ldap://ldap.forumsys.com:389)
LDAP_AUTH_PRINCIPAL=your-principal   # (example: cn=HUMIOUSERNAME,dc=example,dc=com)
```

`AUTHENTICATION_METHOD=ldap` turns on "simple" ldap checking using an ldap bind.

`LDAP_AUTH_PROVIDER_URL` is the URL to connect to. It can start with either
`ldap://` or `ldaps://`, which selects plain and SSL connections respectively.

`LDAP_AUTH_PRINCIPAL` can be left unset, in which case the username is used directly when binding to the server.
If it is set, the token `HUMIOUSERNAME` is replaced with the username, and the resulting string is used as principal.

The URL can be `ldap:/` or `ldaps:/`.  If using `ldaps:/`, you can configure Humio to work with the a server
using a self-signed certificate by specifying `LDAP_AUTH_PROVIDER_CERT` to be the PEM-format value of the certificate.  If this config parameter is not specified, trust is established using the docker container's regular ca authority infrastructure.

Since docker does not support newlines i environment variables, replace newlines with `\n` using something like this:

```echo LDAP_AUTH_PROVIDER_CERT=`cat cert.pem | perl -pe 's/\n/\\\\n/g'` >> humio-config.env```

The result should look like this in the `humio-config.env` file:

```shell
LDAP_AUTH_PROVIDER_CERT=-----BEGIN CERTIFICATE-----\nMII...gWc=\n-----END CERTIFICATE-----\n
```

## LDAP-search (using a bind user)

If LDAP/AD requires login with the exact DN, then it is possible to first do a search for the DN using
a low-priviledge bind username, and then successively do the login with the correct DN.  
To enable this, use this alternative property set:

```shell
AUTHENTICATION_METHOD=ldap-search
LDAP_AUTH_PROVIDER_URL=your-url       # (example: ldap://ldap.forumsys.com:389)
LDAP_SEARCH_DOMAIN_NAME=your-domain   # (example: example.com)
LDAP_SEARCH_BASE_DN=search-prefix     # (example: ou=DevOps,dc=example,dc=com)
LDAP_SEARCH_BIND_NAME=bind-principal  # (example: cn=Bind User,dc=example,dc=com)
LDAP_SEARCH_BIND_PASSWORD=bind-password
LDAP_SEARCH_FILTER=custom-search-filter # (Optional, example: (uid={0}))
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
and one on `userPrincipalName=%HUMIOUSERNAME%@%LDAP_SEARCH_DOMAIN_NAME%` in the subtree specified by `LDAP_SEARCH_BASE_DN`,
using the bind-principal/password. Here `%HUMIOUSERNAME%` is what the user entered at the login prompt.


If either of those searches returns a "distinguishedName", then
that DN is used to login (bind) with the end-user provided password.
A search for `(& (dn={0})(objectCategory=user))` is then performed in the new context,
with the DN found as further validation of that context.

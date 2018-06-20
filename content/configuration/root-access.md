---
title: Root Access
---

Root users are users with the priviledges required to act as systems administrators for the Humio cluster. They have the access rights to add and remove other users to the system and manage aspects that affect all repositories. By default, root users are also members of all repositories. This is controlled by the [ENFORCE_AUDITABLE]({{< relref "audit-logging.md#permissions-and-enforce-auditable-mode" >}}) setting.

## Root Access Token {#root-token}

If you have SSH access to the machine running Humio, you can always
perform API request via `127.0.0.1:8080` or any other way of getting
HTTP request to the Humio server using the special API token for root
access. The token is re-created every time the server starts, and
placed in the file `/data/humio-data/local-admin-token.txt`. The token
allows root access on the API for anyone able to read this file.

The root token can be used for creating initial setup and
configuration e.g. setting up users and repositories.  It's also
useful for running scripts/integrations on the local server, for
provisioning or daily maintenance purposes, in particular for scripts
running on the same server with read-access to the token file.

{{% notice note %}}
Since the token is re-generated on every server startup, it is not suitable as a long-term API token.
For long-term API tokens, add a user with root priviledges and use the API token for that user.
{{% /notice %}}


## Creating Root Users {#create-root}

You can use the [root token]({{< relref "#root-token" >}}) to create root users.
To create a user with root privileges on the server, run:

```shell
TOKEN=`cat /data/humio-data/local-admin-token.txt`
curl http://localhost:8080/api/v1/users \
 -X POST \
 -H "Content-Type: application/json" \
 -H "Authorization: Bearer $TOKEN" \
 -d "{\"email\": \"$EMAIL\", \"isRoot\": true}"
```

When using LDAP `$EMAIL` is the username the user must enter to login,
and need not be an actual email address.

Once that user has been added, you can log on using that user and see your own API token, as described
in [API token]({{< relref "api_tokens.md" >}}).

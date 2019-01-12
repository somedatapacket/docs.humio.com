---
title: "Role Based Authorization"
---

We we use the strict distinction that "authentication" is the subject
of establishing the identity of the user only, and "authorization" is
the subject of deciding which actions a (authenticated) user may
perform.

Roles in Humio are based on group memberships. For the sake of
discussing autorization here please consider roles and groups
synonymous; Being in a role is the same as being member of a group
with that name.

Except for "root access", all authorization in humio is based on group memberhips. "Root access" is a per-user property and independent of roles and groups. See [root access]({{<ref "/configuration/root-access.md">}}).

### Group memberships

A user may be member of zero or more groups. Users not member of any groups can login but can not access anything but the personal sandbox.

The group memberships usually stem from an external directory, such as
your LDAP tree or similar. It is also possible to edit the group
memberships through the UI to support cases where the login mechanism
only supplies the identity of the user and not the group memberships.

<figure>
{{<mermaid align="center">}}
graph LR;
  subgraph Users
    Ext1[User 1]
  end

  subgraph Group memberships
    Ext1 --> A1("Member-of")
    Ext1 --> A2("Member-of")
    Ext1 --> A3("Member-of")
  end

  subgraph Groups
    A1 --> P1["WebLog-users"]
    A2 --> P2["Backend-users"]
    A3 --> P3["bofh"]
           P4["audit-logs"]
  end
{{< /mermaid >}}
<figcaption>Each user is member of a number of groups.</figcaption>
</figure>

Group memberships can be edited using the Humio UI. But for most use cases it makes more sense to automatically generate the memberships from an external source tied to the authentication mechanism being applied.

In order for the login mechanism to capture the roles from the authentication mechanism, the follwing configurations must be set:

```
AUTO_UPDATE_GROUP_MEMBERSHIPS_ON_SUCCESSFUL_LOGIN=true
```

In order for Humio's SAML login module to pick up the roles from the SAMLResponse coming from the SAML SSO server, Humio needs to know the name of the attribute containing the roles.  If this attribute is names `role` you would configure it like this:

```
SAML_GROUP_MEMBERSHIP_ATTRIBUTE=role
```

For LDAP, Humio needs to know the query to perform to get the user's groups, which is defined using the following config properties (for the case of Microsoft Active Directory):

```
LDAP_GROUP_BASE_DN="OU=User administration,DC=humio,DC=com"
LDAP_GROUP_FILTER="(& (objectClass=group) (member:1.2.840.113556.1.4.1941:={0}))"
```

Once setup, a user can see his or her assigned roles in the *Account Settings* pane.

It is also useful to set the following, which creates the user inside Humio once a successful login is established.  That way, operators do not have to add inidividual users.

```
AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN=true
```

With the auto-create user option (and role-based authorization enabled) the user is only allowed to login if that would result in said user having access to some data.  I.e., the access rights for at least one of the roles that the user has must already be setup.


### Authorization is through group memberships

All access to views and repositories is governed by roles. All access
to objects related to a repository such as dashboards and alerts are
checked against the roles of the current user on the repository.

<figure>
{{<mermaid align="center">}}
graph LR;
  subgraph Groups
    G1["WebLog-users"]
    G2["Backend-users"]
    G3["bofh"]
  end
  
  subgraph Repository-Permissions
    G1 --> P1["queryPrefix: *<br>canEditDashboard"]
    G2 --> P2["queryPrefix: Restricted=N"]
    G3 --> P3["queryPrefix: *<br>canEditDashboard<br>canEditSavedQueries<br>canManageIngestTokens<br>canEditParsers<br>canEditRepositoryPermissions"]
  end

  subgraph Repo
  P1 --> R1("Weblogs01 repo")
  P2 --> R1
  P3 --> R1
  end

{{< /mermaid >}}
<figcaption>Each group may provide a number of permissions on each repo.</figcaption>
</figure>

The "Repository-Permissions" can come from multiple sources, depending on configuration.

* They can be imported from a file by a job inside Humio that runs at short intervals to refresh them.
* They can be editd in the UI, if your user has "Root access" or the required permission on the Repository.
* They can be updated from an external system by interacting with the same API that the UI uses when editing.

#### Who can edit Repository-Permissions

All Repository permissions on a view can be edited by a user if that
user is member of a group related to that view that has
`canEditRepositoryPermissions` on that relation. In the examples above
that is members of the group `bofh`.

#### Setting up Authorization Rules from a file

Setting up authorization rules is currently done via a JSON file placed on any one of the nodes in the Humio cluster.  The file should be named `humio-data/view-role-prefix-auth.json`, containing a JSON structure like described below.

This config must be set on all nodes, as all nodes must run the same authentication configuration.
```
PREFIX_AUTHORIZATION_ENABLED=true
```

Currently, we only support this model; a future release will enable editig these rules in the UI.

```
{
  "views" : {
     "REPO1" : {
        "ROLE1" : {
	    "queryPrefix": "QUERY1",
	    "canEditDashboard": true
	}
        "ROLE2" : {
	    "queryPrefix": "QUERY2",
	    "canEditDashboard": false
	}
     },
      
     "REPO2" : {
        "ROLE2" : {
	    "queryPrefix": "QUERY3"
	}
        "ROLE3" : {
	    "queryPrefix": "QUERY4"
	}
     },
     
      ...
  }
}
```

This means that 

- if a user is in `"ROLE1"` then the user has access to `"REPO1"`, and anything he or she does is limited to data that matches the query `"QUERY1"`. 
- if a user is in `"ROLE2"` then the user has access to `"REPO1"` and `"REPO2"`, and anything he or she does in `REPO1` is limited to data that matches the query `"QUERY2"`, whereas anything he or she does in `REPO2` is limited to data that matches the query `QUERY3`.

The file `humio-data/view-role-prefix-auth.json` is re-read every 30 seconds.  It is recommended to just put it on only one of the servers.

The query `"*"` gives access to all data, so here is an example where a user in the LDAP group `CN=Admins,OU=Security Groups,OU=serverusers,OU=User administration,DC=humio,DC=com` is given all-access to the `humio-audit` repository.

```
{
   "views" : {
     "humio-audit" : {
       "CN=Admins,OU=Security Groups,OU=serverusers,DC=humio,DC=com" : "*"
     } 
  }
}
```
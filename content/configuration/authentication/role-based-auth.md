---
title: "Role Based Authorization"
---

For on-prem installations, Humio supports role-based authoriation.  At present this only works in combination with LDAP or SAML authentication.

With these configurations, it is possible to (a) import the role assignments from the authentication mechanism, and (b) designate what data/repos can be viewed and queried, and (c) set role-specific query prefixes that control which data is visible to specific users.

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

## Setting up Authorization Rules

This must be set on all nodes:

```
PREFIX_AUTHORIZATION_ENABLED=true
```

Setting up authorization rules is currently done via a JSON file placed on any one of the nodes in the Humio cluster.  The file should be named `humio-data/view-role-prefix-auth.json`, containing a JSON structure like described below.

Currently, we only support this model; a future release will enable editig these rules in the UI.

```
{
  "views" : {
     "REPO1" : {
        "ROLE1" : "QUERY1",
        "ROLE2" : "QUERY2"
     },
      
     "REPO2" : {
        "ROLE2" : "QUERY3",
        "ROLE3" : "QUERY4"
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
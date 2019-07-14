---
title: "User Management"
---

You can configure Humio to run with or without user authentication.
If user authentication is disabled, then everyone with access to the UI or the API can
access everything!

When you run Humio with authentication enabled, each repository has its own set of users.
Humio identifies users by their email address, and validates each email address
using an OAuth identity provider -- Google, GitHub, or Bitbucket. Humio
can also check usernames and passwords using your local LDAP service.

There are three levels of users: 'normal', 'administrator', and 'root':

* Normal users can only access and query data, including managing dashboards and saved queries
* Administrators can also add and remove other users to a Repository and make them administrators of the Repository.
* 'Root' users can add Repositories and create new root users.

You can create your initial users with 'Root' access through the HTTP API.
See [how to gain root access using a local access token]({{< ref "root-access.md" >}}).

You can manage Users and their rights using the 'Repository' web page in Humio.
Root users (apart from the initial one) can get added through the 'Administration'
page when you are logged in as a root user.

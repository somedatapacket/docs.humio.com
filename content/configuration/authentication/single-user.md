---
title: Running Humio with a single user
menuTitle: Single User
---

Single user authentication is an easy way to get started with Humio,
but with added security compared to the no-authentication mode, in
that you need a password to login to Humio. The login username is
`developer`.

{{% notice note %}}
Be advised that the **password is stored in clear-text in the Humio
configuration file** and thus anybody with read-permissions to that file
will have access to the password. The single user authentication
method is meant as a quick way to get started, but for productions
systems you should use some of the multi-user authentication methods.
{{% /notice %}}

To start Humio in single-user mode you need to specify the following
two configuration settings:

```shell
AUTHENTICATION_METHOD=single-user
SINGLE_USER_PASSWORD=<your-password>
```

You login with the `developer` user account and the password specified
in the configuration file.

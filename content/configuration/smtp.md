---
title: "SMTP Configuration"
menuTitle: "SMTP"
beta: true
aliases: ["/operation/installation/audit_logs/"]
---

Humio can be configured to support sending email notifications. You can either
do this by using Humio's [Postmark Integration]({{< ref "postmark.md" >}}) or using
your own SMTP server.

## SMTP Authentication

Humio only supports the `LOGIN` authentication method for SMTP or using
a local SMTP server without authentication.

{{% notice note %}}
**If you are using Gmail**, you will have to [enable "Less Secure App Access"](https://support.google.com/accounts/answer/6010255?hl=en).
Gmail defines "Less Secure" as not OAuth, which Humio does not support for
SMTP. What is less secure is that you use a fixed password, rather than
per-app OAuth tokens which is arguably more secure.
{{% /notice %}}

## Configuration Options

### `SMTP_HOST`

The hostname or ip of the SERVER server. E.g. `smtp.gmail.com` or `1`

### `SMTP_PORT`

The port to send SMTP messages to. Usually `587`, `465` or `25`.

### `SMTP_SENDER_ADDRESS`

The sender email address ("From" email address) that will be used when sending
emails. E.g. `humio-alerts@example.com`.  

### `SMTP_USERNAME` (Optional)

The username to use for authentication with the SMTP server. If not
specified communication will be done without authentication.
If this is specified you also have to provide `SMTP_PASSWORD` as well.

### `SMTP_PASSWORD` (Optional)

The password to use for authentication with the SMTP server. If not
specified communication will be done without authentication.
If this is specified you also have to provide `SMTP_PASSWORD` as well.

### `SMTP_USE_STARTTLS` (Optional)

If set to `SMTP_USE_STARTTLS=true` Humio will use StartTLS for the connection
to the SMTP server. Defaults to `false`.

---
title: "Email"
---

The email notifier sends alerts as emails. If you are hosting Humio yourself,
it requires that you first configure [Humio's SMTP support]({{< ref "smtp.md" >}}).
Alternatively you can configure Humio to use [Postmark]({{< ref "postmark.md" >}})
SaaS if you don't want to run your own SMTP server.

## Usage

The email notifier will by default send out a nicely styled email with the most
important aspects of an alarm, including a link back into Humio with the result.

Should you for some reason want to modify the e-mail you can do so by checking
"Use custom email template" and fill out the "Message Body Template".

See [Notifier templates]({{< ref "alerts/notifiers/_index.md" >}}) for how
to use our templates. The subject of the email can be configured in much the same

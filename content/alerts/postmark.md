---
title: "Postmark (Email)"
pageImage: "/integrations/postmark.svg"
---

The postmark notifier uses the [Postmark](https://postmarkapp.com/) SaaS solution
to send emails rather than [running your own SMTP server]({{< ref "smtp.md" >}}).

## Usage

The postmark notifier will by default send out a nicely styled email with the most
important aspects of an alarm, including a link back into Humio with the result.

Should you for some reason want to modify the e-mail you can do so by checking
"Use custom email template" and fill out the "Message Body Template".
See [Notifier templates]({{< relref "alerts/notifiers/_index.md" >}}) for how
to use our templates.

{{% notice note %}}
***Postmark configuration***  
Currently Humio supports sending mails using [Postmark](https://postmarkapp.com/).  
Humio must be configured with `POSTMARK_SERVER_SECRET` poitning to a Postmark token to send emails.
{{% /notice %}}

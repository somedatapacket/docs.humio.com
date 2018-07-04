---
title: "Email"
---

The email notifier is our simplest notifier. It takes a list of email
addresses separated by a `,`.

The email notifier will by default send out a nicely styled email with the most
important aspects of an alarm, including a link back into Humio with the result.

Should you for some reason want to modify the e-mail you can do so by checking
"Use custom email template" and fill out the "Message Body Template".
See [Notifier templates]({{< relref "alerts/notifiers/_index.md" >}}) for how
to use our templates.

{{% notice note %}}
***Email configuration***  
Currently Humio supports sending mails using [Postmark](https://postmarkapp.com/) and SMTP.  You can use Postmark
if either (a) you don't have an SMTP server, or (b) if you want to avoid your alert emails to be caught up in spam filters if
you're sending alerts to email adresses outside your own domain.

Humio must be configured with `POSTMARK_SERVER_SECRET` setting a Postmark token to send emails.

To use SMTP, your server must be configured with all these parameters: `SMTP_HOST`, `SMTP_PORT`, `SMTP_SENDER_ADDRESS`, and if you use authentication also the  `SMTP_USE_STARTTLS`, `SMTP_USERNAME`, and `SMTP_PASSWORD` properties.
{{% /notice %}}

If you use gmail for sending notification mails, then you will receive an email with the title 
**Review blocked sign-in attempt**, explaining that you need to enable 'less secure apps'.  You need to follow
the instructions in the mail to allow login to google's SMTP server using username/password. 

---
title: "Email"
---

The email notifier sends alerts as emails.

{{% notice tip %}}
If you are hosting Humio yourself, you must [configure how emails are send]({{< ref "../operations-guide/configuration/basic-configuration/email_configuration.md" >}}).  
{{% /notice%}}

This notifier will by default send out a nicely styled email with the most
important aspects of an alarm, including a link back into Humio with the result.

Should you for some reason want to modify the e-mail you can do so by checking
"Use custom email template" and fill out the "Message Body Template".
See [Notifier templates]({{< ref "alerts/_index.md#templates" >}}) for how
to use our templates. 

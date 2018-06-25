---
title: "Webhooks"
---

Webhooks are our most flexible type of notifier. The webhook notifier can perform a HTTP(S) request to any URL
and can therefore be used to integrate 3rd party services that Humio doesn't have natively integrated.


| Parameter            | Description            |
|-----------------------|-----------------------|
| Endpoint URL          | The URL of the service the webhook is contacting. |
| HTTP Method           | HTTP method of the call, usually `POST` |
| Message Body Template | _Optional_. The body of the HTTP call. Can be of any form: JSON, Text or even XML. The Message Body accept our [Notifier template placeholders]({{< ref "alerts/_index.md#templates" >}}) as well.                      |
| HTTP Headers          | A list of HTTP Headers. We recommend adding a `Content-Type` header with the corresponding content type, i.e. `application/json` for JSON message bodies. Add more headers by hitting the `+` on the right |

{{% notice tip %}}
You can use a service like https://webhook.site/ to test your notifier while you are getting the message body and headers right.
{{% /notice %}}

---
title: Duo security
menuTitle: Duo Security
category: ["Integration"]
aliases: ["ref/duo"]
---

[Duo security](https://duo.com) provides a great way of authenticating your users for your on-prem Humio installation 

## Prerequisites

* DAG installed and configured with at least one Authentication Source
* Familiarize yourself with Humio's [configuration properties]({{< ref "configuration" >}})

## Steps:

1. Start Humio with the following configuration property
  * `AUTHENTICATION_METHOD=none`
2. Add your email address to the list of root users in Humio's [administration section]({{< ref "/configuration/user-management.md" >}})
3. Open your DAG and take note of the following parameters from Applications page
  * "SSO URL"
  * "Entity ID"
  * Save the certificate to a known location on your Humio host
4. Change the following configuration properties in Humio
  * `AUTHENTICATION_METHOD=saml`
  * `PUBLIC_URL` with the URL of where browsers are supposed to reach Humio, i.e. `PUBLIC_URL=https://humio.example.com`
  * `SAML_IDP_SIGN_ON_URL` to the value of "SSO URL" from the DAG
  * `SAML_IDP_ENTITY_ID` to the value of "Entity ID" from the DAG
  * `SAML_IDP_CERTIFICATE` with the location of your DAG certificate, i.e. `SAML_IDP_CERTIFICATE=/certs/dag.crt`
5. Restart Humio
6. Read the output of `http://$HOST:$PORT/api/v1/saml/metadata` and take notes of the following values
  * `md:EntityDescriptor#entityID`, which should be a url starting with your `PUBLIC_URL` followed by `/api/v1/saml/metadata`
  * `md:AssertionConsumerService#Location`, which should be a url starting with your `PUBLIC_URL` followed by `/api/v1/saml/acs`
7. Log into your Duo account and add a new ["Generic SAML Service Provider"](https://duo.com/docs/dag-generic), where
  * "Entity ID" is the value of `md:EntityDescriptor#entityID`
  * "Assertion Consumer Service" is the value of `md:AssertionConsumerService#Location`
  * "NameID attribute" should be set to `email`
8. [Save the configuration file](https://duo.com/docs/dag-generic#create-your-cloud-application-in-duo) and [upload it to your DAG](https://duo.com/docs/dag-generic#add-your-cloud-application-to-duo-access-gateway)
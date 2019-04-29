---
title: "Security Disclosures"
weight: 1000
aliases: []
rss:
  href: "/security-disclosures/index.xml"
  title: "Humio Security and Privacy Disclosures"
---

## Disclosure Policy

We are committed to provide responsible disclosure on security and privacy related incidents.  

As such, we expect that security or privacy related incidents are reported directly to us via support@humio.com (or another direct communication channel) and in return we will verify the incident and report the problem as fast as possible.  This means that we will report the issue (and possible fixes) directly to affected customers so that they have time to mitigate the issue before we report the issue publicly.  For privacy-related incidents that affect users on our hosted services we will report the incident directly to the users and to relevant authorities.

As a concequence of the above policy, it may take several days before we make a public disclosure about a problem.

We do provide bug bounties for serious security issues.  Also, please let us know if you would like to be mentioned by name as the originator of a incident report.


## 2019-04-04
**Fixed in 1.5.6**

We were made aware of a vulnerability in our LDAP integration, for on-prem customers using `AUTHENTICATION_METHOD=ldap` with an ldap service allowing anonymous bind;  it is not relevant for customers using the `ldap-search` authentication method.  This is a problem for all releases prior to 1.5.6.

- Users logging in with an empty password with such a configuration would be let in without further authentication which is a surprising side effect of the default configuration for some ldap products (see description here: https://ldap.com/ldapv3-wire-protocol-reference-bind/#simple-bind-operation)
- operators can search for `#type=humio loglevel=INFO class=*LdapBindLocalLogin @rawstring="*=0"` in the humio repository to identify potential breaches.

No customers on our cloud services were affected by this bug.  Initially we only disclosed this to the customers we knew were utilizing a configuration where this could be a problem.

## 2019-03-25
**Fixed in 1.5.2**

We were made aware of a vulnerability in the authentication for the `audit-log` repo allowing users to access data for other users when querying using the `/query` API.

This is a serious bug which could potentially have leaked information about our customers; we were however able to verify that no customers on our cloud services were affected by this bug. 

## 2018-12-20
**Fixed 2018-12-20**

We received a notification that our demo-site `demo.humio.com` exposed the email addresses of other users on the website.  This was available in the ‘settings’ -> ‘members’ page for the GitHub data repository on demo.humio.com.  No information other than email addresses was exposed – not names, IP addresses or any other information.

This issue is only for the demo website, not for any of our production services. 

We only have concrete knowledge of a single incident where someone saw the list (the reporter of the incident, thanks!), but we cannot guarantee that someone else on the list has retrieved and stored it.  

We have stopped the service of the demo site, and are fixing the code and configuration so that this does not happen again.

We are truly sorry this happened. Our team is reviewing all of our other processes and procedures to ensure no personal information is exposed elsewhere.

## 2017-05-14

Sunday night at 22:53 UTC our build server was compromised.  An attacker used the CVE-2017-1000353 vulnerability in Jenkins to run a monero (crypto coin) miner.

With the help of the security team at Chainalysis, we have been able to determine, with high confidence, that no information was leaked as a consequence of the server being compromised.  

To repeat: we have been able to determine that it is highly unlikely that any information has been leaked.  This is the case for both information relating to our SaaS customers and our on-premise customers.  Likewise, none of the releases available to customers have been affected.  The vulnerability was, as far as we have been able to determine, only exploited to run the said mining program to the effect that our build server became so slow that we were unable to do a build.

While doing this security investigation however, we have found some things we would like to improve, and thus we’re now in the process of rebuilding our infrastructure from scratch. As a result, some SaaS customers can expect observe short service outages on the order of ~5minutes over the next few days as our we update DNS to a rebuilt production environment.

In the process we have also found the attacker’s command-and-control server, which also lists the ~2700 other hosts that have been attacked in a similar way.  We are working on the best way to provide information to those unfortunate fellows.

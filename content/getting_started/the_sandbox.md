---
title: The Sandbox
weight: 3
---

In Humio all users have a private [TODO](Physical Repository) called The Sandbox.

The sandbox has the following limitations compared to ordinary Physical
Repositories:

- You cannot change retention
- You cannot add multiple users


## Use-cases

Based on wether you are using Humio On-Prem or Humio Cloud the use-cases for
the sandbox differ slightly:

### Cloud

Free Humio Cloud users use the sandbox as their primary storage.
It is perfectly suited for smaller projects with low retention requirements
and no need for multiple user access.

By creating Virtual Repositories that read from the Sandbox, you can easily
create specialized repositories for each of your services and systems. See
[TODO](Using Virtual Repositories).

### On-Prem

You can use your sandbox as a testing area where you can create
parser and ingest data without having to create a new Physical Repository,
or impact one of your existing repositories.


## In-App Tutorial uses your sandbox

When you run [Humio's In-App tutorial]({{< relref "tutorial.md" >}}) also uses the sandbox as storage, so
don't be surprised to find tutorial events mixed with your own.

## Not Enough?

If the sandbox is not enough consider upgrading your Cloud account to Humio Pro
or [hosting your own Humio cluster](https://www.humio.com/download).

---
title: "Configuring Webhooks to Trigger Shell Scripts"
---

Alerts are actionable and one way to service them is by triggering a script on a particular host.  For example, while exploring your logs and metrics using Humio you might notice that occasionally a message arrives informing you that a system's root partition is filling up.  You decide to make this into an alert and notify everyone via Slack so that someone can ssh into that system and run `sudo apt-get -y autoremove` (assuming you're on a Debian-based system).  But then you realize that the cleanup required could be automated, you could write a script that fixes this issue without human intervention and one fewer notification in Slack that might go unseen for too long.  Great idea, but how can Humio trigger a cleanup script living on some other host?  Here is where webhooks can bridge the gap.  This guide will show you how to setup and run a program that will listen for these alerts by providing "hooks" that are really just RESTful HTTP GET or POST calls, which is where the name comes from, "web" + "hooks".  These simple web services or "hooks" then execute the scripts on the system they are running on.  In this way you can use Humio to automate and resolve all sorts of issues without anyone needing to get a human involved in the process.  And don't forget to write more log messages from these scripts and feed those back into Humio as well, just so you can be sure everything is working as intended.

Here is an outline of the steps required to enable this process.  We assume for the sake of simplicity that you have the following:

* Humio is setup, operational, and ingesting your log data.
* A separate host system, let's call it the "target", where you'd like to run a script when alerted.
* A script, or other executable you'd like to trigger on that host system
* A network that allows traffic to routed from Humio to the target system.

## Setup on the target system, where the script will run

Webhooks are user-defined HTTP callbacks.  In our case it's the Humio server making an HTTP request using a URL you supply.  This is just another use of a RESTful pattern in practice.  Humio will issue an HTTP POST to the supplied URL and include in that request's body the information you provide.  The target system then runs a process that is essentially a simple web server listening for requests, that's the URL.

In this example, the target system has:

* a DNS name `target.example.com` that resolves to a routable IP address, and
* a script in `/var/scripts/cleanup.sh` that you'd like to trigger.

The agent that will run on the host and listen for the notification is called [webhook](https://github.com/adnanh/webhook).  This is a simple program designed to advertise RESTful HTTP endpoints known as "webhooks" (hence the name) that when triggered via HTTP/GET or POST will execute scripts.  While the authors of this open source program intended it to be used with the Hookdoo service it is a general purpose tool and in our case we're just reusing it and not their service.

### Installing Webhook
Find the [release](https://github.com/adnanh/webhook/releases) appropriate for your system, and [install](https://github.com/adnanh/webhook#installation) it.  This is a program written to integrate with the Hookdoo service, but in our case we're just reusing their tool and not their service.  If you're on Linux you'll eventually want to [setup a startup script](https://www.linux.com/learn/understanding-and-using-systemd) that will execute this program and restart it when necessary.

Once you have the `webhook` binary in your path you'll need to write a simple configuration script in JSON.  The configuration file lists the endpoints to make available on this system and associates them with the script to execute when that endpoint is triggered.  You can have as many endpoint/script pairs as you'd like.  The target can been a script or any other executable file you designate.

Begin by creating an empty file named `hooks.json`.  This file will contain an array of hooks the `webhook` will serve.  Check the [hook definition page](https://github.com/adnanh/webhook/wiki/Hook-Definition) to see the detailed description of what properties a hook can contain, and how to use them.

Let's define a simple hook named `cleanup-webhook` that will run our `cleanup.sh` script located in `/var/scripts/cleanup.sh`.  Make sure that your bash script has `#!/bin/sh` shebang on top and is executable (`chmod +x cleanup.sh`).

Create a file that will define the webhooks available on this system, we'll call it `hooks.json` but you can call it anything you'd like.  Here's what it should look like:
```json
[
  {
    "id": "cleanup-webhook",
    "execute-command": "/var/scripts/cleanup.sh",
    "command-working-directory": "/tmp"
  }
]
```

* `id` - is simply a name you've given the hook, it should be unique in this file, but otherwise it can be whatever you'd like it to be.
* `execute-command` - is the full path to the script you'd like to run when this webhook triggers.
* `command-working-directory` - is the path that the script will find as it's current working directory when executing.

You can now run the `webhook` binary we downloaded earlier using.
```bash
$ /path/to/webhook -hooks hooks.json -verbose
```

It will start up on default port 9000 and will provide you with one HTTP endpoint.
```http
http://yourserver:9000/hooks/redeploy-webhook
```

This endpoint is what you'll use in Humio's webhook alert configuration, so copy it and move on to the next step.  The `yourserver` part can either be an IP address of the host or the DNS name that resolves to the IP of the host just like any other HTTP URI.  For other questions about this program please take a look at their [documentation](https://github.com/adnanh/webhook/wiki) and then let us know if you have questions on our Slack channel `MeetHumio`.

{{% notice tip %}}
One final note about webhooks in general, they are a good tool but once setup anyone with a route to the host could trigger the hook and run the script potentially causing harm or gaining access to data that is sensitive.  If you want `webhook` to serve secure content have a verifiable identity you'll want to use HTTPS.  Simply add to the command line which launches `webhook` the `-secure` flag and reference a certificate using `-cert /path/to/cert.pem` and `-key /path/to/key.pem` flags.  Make sure you have a system in place to generate, rotate and protect these self-signed certificates and that the system running Humio system is setup to acknowledge the veracity of them.  If you have a certificate signed by a certificate authority, then the cert file name should be the concatenation of the server's certificate followed by the CA's certificate.
{{% /notice %}}

## Setup on Humio

In Humio events can cause alerts and trigger notifiers.  The first thing to do is setup an [alert]({{< ref "/alerts/_index.md" >}}).  Alerts in turn trigger notifiers, in this case we want a [webhook]({{< ref "webhook.md" >}}) notifier.

Give your new webhook a name, in this example we'll call it "Cleanup YourServer when disk space is low".  Next, fill in the "Endpoint URL" field with the URL you saved from the previous step.
```http
http://yourserver:9000/hooks/redeploy-webhook
```

The "message body template" can be blank or contain information your webhook will recieve and potentially use.  This will be the body of the POST request which the `webhook` tool makes available to scripts, for this example it's not necessary.

That's it, save your notifier and start the `webhook` server and the next time the alert fires your script on the remote system will be triggered.

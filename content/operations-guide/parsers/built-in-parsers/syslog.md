---
title: syslog
aliases: ["/parsers/built-in-parsers/syslog"]
---

This parser aims to be compatible with a variety of syslog formats seen in the wild. This includes RFC 3164 and RFC 5424. The parser does not implement every aspect of the syslog RFCs but is instead liberal in what it accepts.


## Example Input

```
<34>1 2003-10-11T22:14:15.003Z mymachine.example.com su - ID47 - BOM'su root' failed for foo on /dev/pts/8
```

```
<34>1 2003-10-11T22:14:15.003Z server1.com sshd – – pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=10.0.2.
```

```
<34>Oct 11 22:14:15 mymachine su: 'su root' failed for foo on /dev/pts/8
```

```
Oct 11 22:14:15 su: 'su root' failed for foo on /dev/pts/8
```


If no timezone is specified, as seen above in the two last examples, the parser defaults to UTC time. This can be changed by creating a new parser by cloning this one and changing `timezone="UTC"` to e.g. `timezone="Europe/Paris"`.

The parser also leverages Humio's built-in [key-value parser]({{< ref "kv.md" >}}).

{{% notice info %}}

The parser [syslog-utc]({{< ref "syslog.md" >}}) will likely have slightly better performance in the case where you are dealing with this specific format.

{{% /notice %}}

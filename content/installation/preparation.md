---
title: Preparation
menuTitle: Preparation
weight: 3
---

## Enable Authentication

{{% notice tip %}}
If you are just experimenting and playing around with Humio, you can probably
skip this page. **For production deployments you want to set up authentication.**
{{% /notice %}}

If authentication is not configured Humio runs in `NO_AUTH` mode, meaning that there
are no access restrictions at all – anyone with access to the system, can do
anything.

Refer to the [Authentication Configuration]({{< ref "configuration/authentication/_index.md" >}}) for different login options.


## Increase Open File Limit

For production usage Humio needs to be able to keep a lot of files open for sockets and actual files from the file system. The default limits
on unix systems are typically too low for any significant amount of data and concurrents users.

You can verify the actual limits for the process using

```shell
PID=`ps -ef | grep java | grep humio-assembly | head -n 1 | awk '{print $2}'`
cat /proc/$PID/limits | grep 'Max open files'
```

The minimum required settings depend on the number of open network connections and datasources.
There is no harm in setting these limits high for the Humio process. A value of at least 8192 is recommended.

You can do that by running:

```shell
cat << EOF | tee /etc/security/limits.d/99-humio-limits.conf
# Raise limits for files.
humio soft nofile 250000
humio hard nofile 250000
EOF

cat << EOF | tee -a /etc/pam.d/common-session
# Apply limits:
session required pam_limits.so
EOF
```

**These settings apply to the next login of the Humio user, not to any running processes.**

If you run Humio using Docker then you can raise the limit using the `--ulimit="nofile=8192:8192"` option on the `docker run` command.

---
title: Increase the open file limit
menuTitle: Increase Open File Limit
weight: 3
---

Humio needs to be able keep a lot of files open at a time. The default limits
on unix systems are typically too low for any significant amount of data.

For Humio to perform you need to increase the limit.
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

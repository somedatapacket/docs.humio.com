---
title: "Backup"
---

You can back up your Humio installation by adding a special mounted directory
when you run the Docker container. Humio writes its backup files to this directory.

Currently, this is the only backup strategy. However, Humio is designed to
support other strategies, like backup to AmazonS3.

### Steps

1. Create an empty directory on the host machine to store data for Humio:

```shell
mkdir /humio-backups-on-host
```

{{% notice tip %}}
We recommend creating the backup directory on a different disk from the main
Humio data directory.
{{% /notice %}}

2. Edit the Humio configuration file to set the backup parameters. Add the following lines:


``` shell
BACKUP_NAME=humio-backup
BACKUP_KEY=mysecretkey-myhost-+R+q(AB9QG86xZMCKGyj
```

{{% notice note %}}
Humio encrypts all backups with a secret key. This means that you can safely
store backups on an unencrypted disk, or send them over the Internet.  
Keep the secret key safe, and store it in another place. You cannot recover
it if you lose access to it.
{{% /notice %}}

3. Run Humio using the Docker run command. Add the following argument to the command. It maps the backups directory on the host (here, `/humio-backups-on-host`) to the `/backup` directory in the container:

```shell
-v /humio-backups-on-host:/backup
```

Humio will start backing up data to the specified directory.

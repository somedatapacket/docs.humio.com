---
title: "Backup"
aliases: ["configuration/backup"]
---

Humio has a built-in backup facility. It only requires a separate
directory for Humio to write to, preferably on another disk or network
drive from the data directory. When configured, Humio keeps a full
backup of the current state in this directory, and also deletes old
copies when e.g. retention deletes them from the main copy. Humio is
able to start with an empty data directory and restore the previous
state from such a backup. The files written on the backup drive are
encrypted using a secret provided in the configuration of Humio to
allow storing the backup on e.g. a network drive where others may have
read access.

Currently this is the only backup strategy. However Humio is designed to
support other strategies like e.g. Amazon S3 Backup.

Alternatively, you can back up your Humio installation by using any
backup software that is able to backup all the files in the Humio data
directory. Note that the software need to support "sparse files" to be
efficient.


### Steps

You can back up your Humio installation by adding a special mounted directory
when you run the Docker container. Humio writes its backup files to this directory.

1. Create an empty directory on the host machine to store data for Humio:

```shell
mkdir /humio-backups-on-host
```

{{% notice tip %}}
We recommend creating the backup directory on a
different disk from the main Humio data directory. Make the directory
created a mount point for a network drive or other similar separation
form the main data drive.
{{% /notice %}}

2. Edit the Humio configuration file to set the backup parameters. Add the following lines:

```shell
BACKUP_NAME=humio-backup
BACKUP_KEY=mysecretkey-myhost-+R+q(AB9QG86xZMCKGyj
```

{{% notice note %}}
Humio encrypts all backups with a secret key that you provide. This means that you can safely
store backups on an unencrypted disk, or send them over the Internet.  
Keep the secret key safe and store it in another place. You cannot recover
the backup if you lose access to it!

If you lose the secret, delete all the files in the backup,
or provide a new location to backup to, and start over.
Humio will then write a fresh backup.
{{% /notice %}}

3. Run Humio using the Docker run command. Add the following argument to the command. It maps the backups directory on the host (here, `/humio-backups-on-host`) to the `/backup` directory in the container:

```shell
-v /humio-backups-on-host:/backup
```

Humio will start backing up data to the specified directory.

### Not running Docker?
The procedure is mostly the same.
Instead of mounting the directory using "-v", you specify the location using "BACKUP_DIR".
A full example configuration is then:

``` shell
BACKUP_NAME=humio-backup
BACKUP_KEY=mysecretkey-myhost-+R+q(AB9QG86xZMCKGyj
BACKUP_DIR=/mnt/my-net-server/humio-backup01
```

## Restoring From Backup {#restore}

#!/bin/sh

## Server name
NAME=$(hostname -A)

## ipv4 address
IP=$(ip a | grep -e "inet\s172.*")


## Mount credentials
SHARENAME="//backup_folder/scripts/jira"
MOUNTPOINT="/backups"
USERNAME="username"
PASSWORD="password"

### Backup Folder
BACKUP_FOLDER=/$MOUNTPOINT/system

## DB_Settings
BACKUP_DB_PATH=/$MOUNTPOINT/db
USER="postgres"
PGPASSWORD="password"
export PGPASSWORD
DB_NAME="base"
DATE="`date +%Y-%m-%d_%H-%M-%S.sql_dump.gz`"

## Binaries ###
TAR="$(which tar)"

## Today + hour in 24h format
NOW=$(date +%Y%m%d%M)

## Mount share
mount -t cifs $SHARENAME $MOUNTPOINT -o username=$USERNAME,password=$PASSWORD 2> /dev/null

## If the network folder is mounted, it creates a backup, if no - a letter is sent with the error

if grep -qP "\s+$MOUNTPOINT+\s" /proc/mounts; then

## Archiving directories and copying them to the backup server
DST="$BACKUP_FOLDER/$NOW"
[ ! -d "$DST" ] && mkdir -p "$DST"
$TAR -czf "$DST/jira_conf.tgz" -P /opt/atlassian/
$TAR -czf "$DST/jira_data.tgz" -P /var/atlassian/

## Dump databases
pg_dump -U $USER -d $DB_NAME | gzip > $BACKUP_DB_PATH/$DB_NAME-$DATE
unset PGPASSWORD

### clear ###
find /$MOUNTPOINT/system/ -maxdepth 1 -mindepth 1 -type d -mtime +30 -exec rm -r {} \;
find /$MOUNTPOINT/db/ -maxdepth 1 -mindepth 1 -type f -mtime +90 -exec rm -r {} \;

# Unmount backup folder
umount $MOUNTPOINT

else

## Send alert message

echo "Server: $NAME\nProblem: mounting a network drive\nip:$IP " | mail -s "Server backup problem" monitoring@email.com

  exit
fi

exit

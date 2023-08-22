#!/bin/bash

# Set variables
BORG_REPO="prod backup server borg repo full path/$(hostname)"
BACKUP_SERVER="backup server ip or dns"
BACKUP_USER="backup server username"
LOCAL_REPO="local borg repo full path"
SSH_KEY="/ssh key full path"
SOURCE_DIRS="/opt /tmp and otheryou want to backup"
# Archive name with timestamp
ARCHIVE_NAME="$(hostname)-$(date +'%Y-%m-%d_%H-%M')"

# Set the environment variable
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=1

# Check if the backup repository exists
if ssh $BACKUP_USER@$BACKUP_SERVER "[ ! -d '$BORG_REPO' ]"; then
    echo "Borg init..."
    borg init -e none $BACKUP_USER@$BACKUP_SERVER:$BORG_REPO
else
    echo "Repository alredy exists"
fi

#borg init -e none $BACKUP_USER@$BACKUP_SERVER:$BORG_REPO


for dir in "${SOURCE_DIRS[@]}"; do
    echo "Backing up $dir..."
    borg create -s --list --progress $BACKUP_USER@$BACKUP_SERVER:$BORG_REPO::$ARCHIVE_NAME $SOURCE_DIRS $dir
    if [ $? -eq 0 ]; then
        echo "Backup of $dir completed successfully."
    else
        echo "Backup of $dir failed."
    fi
done


# Prune old backups on the local repository
borg prune -v $BACKUP_USER@$BACKUP_SERVER:$BORG_REPO --keep-daily=7 --keep-weekly=4 --keep-monthly=12 --keep-yearly=1 --keep-hourly=12



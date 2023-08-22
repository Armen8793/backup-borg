#!/bin/bash

# Set variables
BORG_REPO="/home/ansible-abb/backup-test/$(hostname)"
BACKUP_SERVER="192.168.18.53"
BACKUP_USER="ansible-abb"
LOCAL_REPO="/home/armen/backup/borg"
SSH_KEY="/home/armen/Downloads/ansible-abb"
SOURCE_DIRS="/opt"
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
borg prune -v $BACKUP_USER@$BACKUP_SERVER:$BORG_REPO --keep-daily=7 --keep-weekly=4 --keep-monthly=1




#!/bin/bash

# Set variables
BORG_REPO="your backup server borg repo here/$(hostname)"
BACKUP_SERVER="backup server dns or ip"
BACKUP_USER="backup username"
LOCAL_REPO="local borg repo full path"
SSH_KEY="ssh key full path"
SOURCE_DIRS="directories which you want to backup"
# Archive name with timestamp
ARCHIVE_NAME="$(hostname)-$(date +'%Y-%m-%d_%H-%M')"
current_hostname=$(hostname)
VOLUMES="/path/to/pg_volumes.txt"
PGDUMP_DIR="/root/postgres-dump"
PSQL_USER="postgres user"
PSQL_PWD="postgres password"
PGB_PORT="6432"

# Set the environment variable
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=1

# Check if the backup repository exists
if ssh $BACKUP_USER@$BACKUP_SERVER "[ ! -d '$BORG_REPO' ]"; then
    echo "Borg init..."
    borg init -e none $BACKUP_USER@$BACKUP_SERVER:$BORG_REPO
else
    echo "Repository alredy exists"
fi


if [[ $current_hostname == *"postgresql"* ]]; then
    echo "Hostname contains 'postgresql'."
    PGPASS_FILE="/root/.pgpass"
    echo "localhost:$PGB_PORT:*:$PSQL_USER:$PSQL_PWD" > "$PGPASS_FILE"
    chmod 600 "$PGPASS_FILE"
    pg_dump -h localhost -p $PGB_PORT -U $PSQL_USER > backup1.sql
else
   echo "Hostname does not contain 'postgresql'."
fi
#borg init -e none $BACKUP_USER@$BACKUP_SERVER:$BORG_REPO

#for dir in "${SOURCE_DIRS}"

if [[ $current_hostname == *"docker"* ]]; then
    for volume in $(docker volume ls --filter "name=logs" --format={{.Name}}); do
        VOLUME_BACKUP=$(docker volume ls --filter "name=${volume}" --format={{.Name}})
        echo ${VOLUME_BACKUP} >> backup-dirs.txt
    done

    for volume in $(docker volume ls --filter "name=exch" --format={{.Name}}); do
        VOLUME_BACKUP=$(docker volume ls --filter "name=${volume}" --format={{.Name}})
        echo ${VOLUME_BACKUP} >> backup-dirs.txt
    done

    for volume in $(docker volume ls --filter "name=data" --format={{.Name}}); do
        VOLUME_BACKUP=$(docker volume ls --filter "name=${volume}" --format={{.Name}})
        echo ${VOLUME_BACKUP} >> backup-dirs.txt
    done

    for volume in $(docker volume ls --filter "name=monitoring" --format={{.Name}}); do
        VOLUME_BACKUP=$(docker volume ls --filter "name=${volume}" --format={{.Name}})
        echo ${VOLUME_BACKUP} >> backup-dirs.txt
    done
    #echo "Hostname contains 'docker'."
    #logs_directory="/var/lib/docker/volumes"
    #find "$logs_directory" -type d -name "*logs*" -exec find {} -type f \; | while read -r log_file; do
        #log_filename=$(basename "$log_file")
        #scp -i "$SSH_KEY" "$log_file" "$BACKUP_USER@$BACKUP_SERVER:$BORG_REPO/$current_hostname-volumes-backup"
    #done

    #find "$logs_directory" -type d -name "*exch*" -exec find {} -type f \; | while read -r log_file; do
        #log_filename=$(basename "$log_file")
        #scp -i "$SSH_KEY" "$log_file" "$BACKUP_USER@$BACKUP_SERVER:$BORG_REPO/$current_hostname-volumes-backup"
    #done

    #find "$logs_directory" -type d -name "*data*" -exec find {} -type f \; | while read -r log_file; do
        #log_filename=$(basename "$log_file")
        #scp -i "$SSH_KEY" "$log_file" "$BACKUP_USER@$BACKUP_SERVER:$BORG_REPO/$current_hostname-volumes-backup"
    #done

    #find "$logs_directory" -type d -name "*monitoring*" -exec find {} -type f \; | while read -r log_file; do
        #log_filename=$(basename "$log_file")
        #scp -i "$SSH_KEY" "$log_file" "$BACKUP_USER@$BACKUP_SERVER:$BORG_REPO/$current_hostname-volumes-backup"
    #done
#fi

for dir in "$(cat ~/borgbackup-dev/backup-dirs.txt)"; do
    echo "Backing up $dir..."
    borg create -s --progress $BACKUP_USER@$BACKUP_SERVER:$BORG_REPO::$ARCHIVE_NAME $dir
    if [ $? -eq 0 ]; then
        echo "Backup of $dir completed successfully."
    else
        echo "Backup of $dir failed."
    fi
done


# Prune old backups on the local repository
borg prune -v $BACKUP_USER@$BACKUP_SERVER:$BORG_REPO --keep-daily=7 --keep-weekly=4 --keep-monthly=1





#!/bin/bash

# Set variables
SOURCE_DIR="/path/to/dir/which/you/want/to/backup"
REMOTE_USER="username"
REMOTE_HOST="ip or dns"
BACKUP_REPO="remote borg repo"
BACKUP_NAME="$(hostname)-$(date +%Y-%m-%d_%H-%M-%S)"

# Run BorgBackup via SSH
ssh $REMOTE_USER@$REMOTE_HOST "borg create -v --stats $BACKUP_REPO::$BACKUP_NAME $SOURCE_DIR"

# Prune old backups on remote host, retaining the last 3
ssh $REMOTE_USER@$REMOTE_HOST "borg prune -v --list $BACKUP_REPO --keep-within=7d --keep-weekly=3"


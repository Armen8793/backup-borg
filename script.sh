#!/bin/bash

# Set variables
SOURCE_DIR="/home/armen/my-abb-demo"
REMOTE_USER="armen"
REMOTE_HOST="192.168.1.210"
BACKUP_REPO="/home/armen/remote-backup/borg"
BACKUP_NAME="$(hostname)-$(date +%Y-%m-%d_%H-%M-%S)"

# Run BorgBackup via SSH
ssh $REMOTE_USER@$REMOTE_HOST "borg create -v --stats $BACKUP_REPO::$BACKUP_NAME $SOURCE_DIR"

# Prune old backups on remote host, retaining the last 3
ssh $REMOTE_USER@$REMOTE_HOST "borg prune -v --list $BACKUP_REPO --keep-within=7d --keep-weekly=3"


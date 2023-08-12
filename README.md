# backup-borg

Install BorgBackup:
Make sure BorgBackup is installed on both your local and remote systems.

Set Up SSH Key Authentication:
On your local system, create an SSH key pair if you haven't already. Then, add the public key to the ~/.ssh/authorized_keys file on the remote host. This enables passwordless SSH access for the backup process.

Create a Repository on Remote Host:
On the remote host, create a Borg repository just like in the previous steps:

bash

borg init --encryption=repokey /path/to/remote/backup/repo

Create a Shell Script for Remote Backup:
Create a shell script similar to the previous example, but this time it will include the necessary SSH connection:
see script.sh
chmod +x script.sh
with crontab -e automate executing the command to send backups to remote host

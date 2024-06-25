#!/bin/bash
# Path
nextcloudPath=/var/www/nextcloud/
occPath=$nextcloudPath\occ
sourcePath=/var/www/nextcloud/
mainDestinationPath=/home/backups/nextcloud/
filesDestinationPath=$mainDestinationPath\files/
databaseDestinationPath=$mainDestinationPath\database/
# Database
dbhost=$(cat $nextcloudPath\config/config.php | egrep "dbhost" | sed 's/^.*\=> *'\''//' | sed 's/'\'',.*$//')
dbname=$(cat $nextcloudPath\config/config.php | egrep "dbname" | sed 's/^.*\=> *'\''//' | sed 's/'\'',.*$//')
dbuser=$(cat $nextcloudPath\config/config.php | egrep "dbuser" | sed 's/^.*\=> *'\''//' | sed 's/'\'',.*$//')
dbpassword=$(cat $nextcloudPath\config/config.php | egrep "dbpassword" | sed 's/^.*\=> *'\''//' | sed 's/'\'',.*$//')
# Verbose
cyan='\e[1;36m'
white='\e[1;37m'
neutral='\e[0;m'
echo -e "${cyan}dbhost : ${white}$dbhost${neutral}"
echo -e "${cyan}dbname : ${white}$dbname${neutral}"
echo -e "${cyan}dbuser : ${white}$dbuser${neutral}"
#echo -e "${cyan}dbpassword : ${white}$dbpassword${neutral}"
read -t 10 -p "The backup will start after 10 seconds" || true
# Destinations creation
mkdir -p $filesDestinationPath
mkdir -p $databaseDestinationPath
chmod -R o-rwx /home/backups/
# Maintenance mode activation
sudo -u www-data php $occPath maintenance:mode --on
# Database backup
mysqldump --single-transaction -h $dbhost -u $dbuser -p$dbpassword $dbname > $databaseDestinationPath\nextcloud-sqlbkp_`date +"%Y%m%d_%H%M%S"`.bak
# Files backup
rsync -Aavx $sourcePath $filesDestinationPath\nextcloud-backup_`date +"%Y%m%d_%H%M%S"`/ --exclude={'data/*','*/files_trashbin/files/*'}
#rsync -Aavx $sourcePath $filesDestinationPath\nextcloud-backup_`date +"%Y%m%d_%H%M%S"`/
# Maintenance mode deactivation
sudo -u www-data php $occPath maintenance:mode --off

# Sauvegarde definitive avec borgbackup
LOG=/root/administration/borg-serveur.log
DATE=`date +%d-%m-%Y_%H:%M:%S`

## sauvegarde du serveur nextcloud.

borg create -C zstd,10 /home/backups/nextcloud-serveur::popaul77-srv-{now} /home/backups/nextcloud

# purge des archives.
borg prune -v --list --stats --keep-daily=7 --keep-weekly=4 --keep-monthly=6 /home/backups/nextcloud-serveur

borg compact --progress --cleanup-commits /home/backups/nextcloud-serveur

## fichier email
echo "--------------------------------------" > $LOG
echo " Sauvegarde serveur le : " $DATE >> $LOG
echo "--------------------------------------" >> $LOG
echo "BORG LIST " >> $LOG

borg list /home/backups/nextcloud-serveur >> $LOG

echo "BORG INFO " >> $LOG

borg info /home/backups/nextcloud-serveur >> $LOG


#cat $LOG | mail -s " Sauvegarde SERVEUR nextcloud popaul77-srv "  -a "From : admin-popaul77-srv<admin@local.net>" jpg@popaul77.org
swaks -t admin@popaul77.org --body /root/administration/borg-serveur.log --h-Subject "Save Cloud-popaul77-srv"

# suppression de la sauvegarde primaire
rm -rf /home/backups/nextcloud/*

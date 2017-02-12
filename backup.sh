#!/bin/bash

#****
# CUSTOM VARIABLES

TMP_BACKUP="/tmp"
LOG_FILE="/var/log/backup-mega.log"
DESTINATION="/mnt/mega/backup"
ENCRYPT_KEY="/root/key.bin"
#FOLDER_TO_BACKUP="/home/luca /home/dido /home/alexander /etc/nginx /var/www /var/ftp"
#****


# DUMP ALL POSTGRES DATABASES

#tmp_Psql=$TMP_BACKUP"/postgres-backup.sql"
#sudo -u postgres -H pg_dumpall > $tmp_Psql
#FOLDER_TO_BACKUP=$FOLDER_TO_BACKUP" "$tmp_Psql

MySQLpwd=$(awk '/MySQLpwd/ {split($0,a,":"); print a[2]}' /root/.backupconf)

# DUMP ALL MySQL DATABASES

printf "\n[DOING ] CREATING MY-SQL DUMP @ $TMP_BACKUP/mysql-backup.sql \n"
tmp_MySQL=$TMP_BACKUP"/mysql-backup.sql"
mysqldump --user=root --password=$MySQLpwd --all-databases > $tmp_MySQL
FOLDER_TO_BACKUP=$FOLDER_TO_BACKUP" "$tmp_MySQL
printf "[ DONE ]"


# DUMP ALL MongoDB DATABASES

tmp_MongoDB=$TMP_BACKUP"/mongo_bck"
mongodump --out $tmp_MongoDB &>/dev/null
FOLDER_TO_BACKUP=$FOLDER_TO_BACKUP" "$tmp_MongoDB


# GENERATES THE ARCHIVE FILENAME
# day1=$(date +"%d-%m-%Y--%H:%M:%S")

day=$(date +"%d-%m-%Y")
day1=$(date +"%Y-%m-%d--%H:%M:%S")
hostname=$(hostname -s)
archive_file="$hostname-$day1"


# PRINTS THE STATUS MESSAGES

printf "\nBacking up $FOLDER_TO_BACKUP to $DESTINATION/$archive_file"
date



# COMPRESS FILES USING tar

printf "\n[DOING ] Compressing files..\n"
tar cz $FOLDER_TO_BACKUP | openssl enc -aes-256-cbc -salt -out $TMP_BACKUP/$archive_file -pass file:$ENCRYPT_KEY
printf "[ DONE ]"

# CHECKS IF THERE IS ENOUGH SPACE ON MEGA AND EVENTUALLY CREATES IT

MEGA_FREE_SPACE=$(megadf | awk 'NR==3 {print $2}')
BCK_SIZE=$(stat --printf="%s" $TMP_BACKUP/$archive_file)
OLDEST_BCK=$(megals | awk '/Root\/sf-backup\//' | head -1 -)

printf "\nBackup Size: $BCK_SIZE"
printf "\nMega Free Space: $MEGA_FREE_SPACE"
printf "\nOldest Backup $OLDEST_BCK"


while (( BCK_SIZE > MEGA_FREE_SPACE )); do
        printf "\nNo Space on MEGA... Deleting: $OLDEST_BCK"
	megarm $OLDEST_BCK
	printf "\n$OLDEST_BCK DELETED"
	MEGA_FREE_SPACE=$(megadf | awk 'NR==3 {print $2}')
	OLDEST_BCK=$(megals | awk '/Root\/sf-backup\//' | head -1 -)
done


# UPLOAD USING MEGATOOL https://megatools.megous.com/man/megatools.html#_megatools

printf "\n[DOING ] Uploading files.."
megaput --path /Root/sf-backup $TMP_BACKUP/$archive_file
printf "\n[ DONE ]"

# sudo cp $TMP_BACKUP/$archive_file $DESTINATION

status=$?

if [ $status -ne 0 ]; then
	echo "error with $status" >> $LOG_FILE
fi

echo ---- $TMP_BACKUP/$archive_file

# DELETE ALL TMP FILES
printf "\n[DOING ] Cleaning Up..\n"
rm -v $TMP_SQL_FILE $TMP_BACKUP/$archive_file
rm -v $tmp_MySQL
rm -rv $tmp_MongoDB
printf "\n[ DONE ]"

# Print end status message.
echo
echo "Backup finished"
date

# TODO
# 	[DONE]- Mongo db dump
#	- define a folder to put the key
#	[DONE] find a solution for the hardcoded mysql paswd
#	[DONE]- Remove old backups from the server
# 	[DONE]- write a script that downloads the last backup, decrypts and uncompresses it on a specific folder

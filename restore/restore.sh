#!/bin/bash

DOWNLOAD_DIRECTORY="/var/tmp"
RESTORE_DIR="/root/restore"

# Takes the last backup and downloads it

download_path=$(megals | sort - | awk '/SFvps/ {a=$0} END{print a}')
printf "[ DOING ]Downloading: $download_path\n"
megaget $download_path --path $DOWNLOAD_DIRECTORY 1>/dev/null
printf "[ DONE ]\n"

# Gets the name of the file from the path
dowloaded_file=${download_path##*/}

# Creats the restore folder
mkdir -p $RESTORE_DIR

# DOWNLOADS and DECRYPTS the file in 
printf "[ DOING ] Uncompressing and decrypt $DOWNLOAD_DIRECTORY$dowloaded_file to restore"
openssl enc -aes-256-cbc -d -salt -in $DOWNLOAD_DIRECTORY"/"$dowloaded_file -pass file:/root/key.bin | tar -zxvf - -C $RESTORE_DIR &>/dev/null
printf "\n[ DONE ] Files are in $RESTORE_DIR\n"

# REMOVES downloaded files

printf "\nCleaning Up..\n"
rm $DOWNLOAD_DIRECTORY"/"$dowloaded_file
printf "\nBackup downloaded and decrypted correctly!\n"

# TODO
#	-  restore all files on proper folders

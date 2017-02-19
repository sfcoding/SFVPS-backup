#!/usr/bin/perl

use warnings;
use strict;

use Config::Simple;


# *** SUB-ROUTINE *** #

sub load_cfg; 		sub mySqlDump; 			sub addToBackup; 
sub mongoDump; 		sub getDate; 			sub getHost;
sub getArchiveName; 	sub compressFiles; 		sub getMegaFreeSpace; 
sub getArchiveSize; 	sub getOldestBackup; 	sub freeSpaceOnMega; 
sub uploadOnMega; 	sub cleanUp; sub execcommand; 
sub mycback;

# *** *** *** *** *** #

# *** GLOBAL VARS *** #

my %cfg;

my $archive_file;
my $tmp_MySQL;   
my $tmp_MongoDB;

# *** *** *** *** *** #


main();

# main subroutine;

sub main {
		
	print getDate." [ LOG ] Loading Configuration File\n";

	load_cfg;
	$archive_file = getArchiveName;
	$tmp_MySQL = "$cfg{'TMP_BACKUP'}/mysql-backup.sql";   
	$tmp_MongoDB = "$cfg{'TMP_BACKUP'}/mongo_bck";

	print getDate." [ LOG ] Performing MySQL Dump\n";
	mySqlDump;
	print getDate." [ LOG ] Performing Mongo Dump\n";
	mongoDump;

	print getDate." [ LOG ] Creating Archive: $cfg{'TMP_BACKUP'}$archive_file\n";
	compressFiles;

	print getDate." [ LOG ] Getting MEGA Free Space\n";
	freeSpaceOnMega;
	print getDate." [ LOG ] Uploading $archive_file on MEGA\n";
	uploadOnMega;
	print getDate." [ LOG ] DONE upload on MEGA!\n";
	print getDate." [ LOG ] Cleaning Up...\n";
	cleanUp;
	print getDate." [ LOG ] Done Backup!\n";

	exit 0;

}

# DUMP ALL MySQL DATABASES

sub mySqlDump {

    my $command = "mysqldump --user=root --password=$cfg{'MYSQL_PWD'} --all-databases > $tmp_MySQL"; 
    execcommand($command,\&mycback);
    addToBackup("FOLDERS_TO_BACKUP",$tmp_MySQL);

}

# DUMP ALL MongoDB DATABASES

sub mongoDump {

    my $command = "mongodump --out $tmp_MongoDB >/dev/null 2>&1";
    execcommand($command,\&mycback);
    addToBackup("FOLDERS_TO_BACKUP",$tmp_MongoDB);

}

# Load configuration file from the root's home

sub load_cfg {

    Config::Simple->import_from("/root/.backupcfg",\%cfg);
    $cfg{"FOLDERS_TO_BACKUP"} = [split / /, $cfg{"FOLDERS_TO_BACKUP"}];

}

# Add a file path to the folder-list to backup

sub addToBackup {

    push @{$cfg{$_[0]}}, $_[1];

}

# Returns the date on a proper format

sub getDate {

    my $out = `date +"%Y-%m-%d--%H:%M:%S"`;
    chomp $out;
    $out;

}

# Returns the name of the host
 
sub getHost {

    my $out = `hostname -s`;     
    chomp $out;
    $out;

}

# Creates the archive name based on date and host-name

sub getArchiveName {

    getHost."-".getDate;

}

# Compress on a tar archive and encrypt it

sub compressFiles {

    `tar cz @{$cfg{'FOLDERS_TO_BACKUP'}} | openssl enc -aes-256-cbc -salt -out $cfg{'TMP_BACKUP'}/$archive_file -pass file:$cfg{'ENCRYPT_KEY'}`;

}

# Returns the free space on MEGA

sub getMegaFreeSpace{

	# `megadf | awk 'NR==3 {print $2}'`;
	(split("Free:  ",(split("\n",`megadf`))[2]))[1];
	
}

# Returns the size of the generated archive

sub getArchiveSize {

	my $archivePath = "$cfg{'TMP_BACKUP'}/$archive_file";	
	`stat --printf="%s" $archivePath`;

}

sub getOldestBackup {
	
	# megals | awk '/Root\/sf-backup\//' | head -1 -
	`megals | awk '/Root\\/sf-backup\\//' | head -1 -`;

}

# Checks if there is enough space on MEGA and eventually create it

sub freeSpaceOnMega {
	
	my $attempts = 5;

	while ( getMegaFreeSpace() < getArchiveSize() ){
		
		my $oldestBKC = getOldestBackup;
		print "[ WARNING ] Not enough space on MEGA...\n";
		print "I need to remove older backups\n";
		print "[ WARNING ] Removing: $oldestBKC\n";

		my ($status,$out) = execcommand("megarm $oldestBKC",\&mycback);
	
		if (($status) == 0){

			print "Removed: $oldestBKC";

		} else {
			
			$attempts--;

			sleep(30);
			print "[ ERROR!!! ] megarm exit status != 0 $status\nOut:$out\n";
				
			if ($attempts == 0){
		
				print "[ WARNING ] Maximum number of attempts reached! exit.. \n";
				exit 1;

			}
		}
	}
	
	print getDate."[ LOG ] Enough Space on MEGA!\n";

}

# Upload the archive on MEGA

sub uploadOnMega {

	my $command = "megaput --path /Root/sf-backup $cfg{'TMP_BACKUP'}/$archive_file";
	my ($status,$out) = execcommand($command,\&mycback);

	if (($status) != 0) {

		print "[ ERROR!! ] Megaput exit status != 0!\n";
		print "[ WARNING ] Backup will be temporary stored here: $cfg{'TMP_BACKUP'}/$archive_file\n";
		print "exit...\n";
		exit 1;

	}
}

# Removes all the generated temp files

sub cleanUp {

	print `rm -rv $tmp_MongoDB $tmp_MySQL $cfg{'TMP_BACKUP'}/$archive_file`;

}

# A bit of functional <3

sub execcommand {

    my $command = shift;
    my $cback   = shift;
    my $out = `$command`;

    if ($?!=0) {

        $cback->($command,$?);
                                    
    }

    return ($?,$out);

}

sub mycback {

    my $command = shift;
    my $status  = shift; 

    print getDate."[ ERROR ] The following command exited with status != 0:\n$command\nstatus:$status\n";

}

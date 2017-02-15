#!/usr/bin/perl

use warnings;
use strict;

use Config::Simple;

sub load_cfg; sub mySqlDump;
sub addToBackup; sub mongoDump;
sub getDate; sub getHost;
sub getArchiveName; sub compressFiles;
sub getMegaFreeSpace; sub getArchiveSize;
sub getOldestBackup; sub freeSpaceOnMega;
sub uploadOnMega;


my %cfg;

my $archive_file = getArchiveName;

load_cfg;
#mySqlDump;
#mongoDump;
#print getArchiveName."\n"; 
#compressFiles;

#getMegaFreeSpace;
#getArchiveSize;
#getOldestBackup;
#freeSpaceOnMega;

uploadOnMega;

print "@{$cfg{'FOLDERS_TO_BACKUP'}}";

sub mySqlDump {

    my $tmp_MySQL = $cfg{"TMP_BACKUP"}."/mysql-backup.sql";   
    `mysqldump --user=root --password=$cfg{"MYSQL_PWD"} --all-databases > $tmp_MySQL`; 
    addToBackup("FOLDERS_TO_BACKUP",$tmp_MySQL);

}

sub mongoDump {

    my $tmp_MongoDB = $cfg{"TMP_BACKUP"}."/mongo_bck";
    `mongodump --out $tmp_MongoDB >/dev/null 2>&1`;
    addToBackup("FOLDERS_TO_BACKUP",$tmp_MongoDB);

}

sub load_cfg {

    Config::Simple->import_from("/root/.backupcfg",\%cfg);
    $cfg{"FOLDERS_TO_BACKUP"} = [split / /, $cfg{"FOLDERS_TO_BACKUP"}];

}

sub addToBackup {

    push @{$cfg{$_[0]}}, $_[1];

}

sub getDate {

    my $out = `date +"%Y-%m-%d--%H:%M:%S"`;
    chomp $out;
    $out;

}

sub getHost {

    my $out = `hostname -s`;     
    chomp $out;
    $out;

}

sub getArchiveName {

    getHost."-".getDate;

}


sub compressFiles {

    `tar cz @{$cfg{'FOLDERS_TO_BACKUP'}} | openssl enc -aes-256-cbc -salt -out $cfg{'TMP_BACKUP'}/$archive_file -pass file:$cfg{'ENCRYPT_KEY'}`;

}

sub getMegaFreeSpace{

	(split("Free:  ",(split("\n",`megadf`))[2]))[1];
	
}

sub getArchiveSize {

	my $archivePath = $cfg{'TMP_BACKUP'}."/$archive_file";	
	`stat --printf="%s" $archivePath`;

}

sub getOldestBackup {
	
	# megals | awk '/Root\/sf-backup\//' | head -1 -
	`megals | awk '/Root\\/sf-backup\\//' | head -1 -`;

}

sub freeSpaceOnMega {

	while ( getMegaFreeSpace() < getArchiveSize() ){
		
		my $oldestBKC = getOldestBackup;
		print "[ WARNING ] Not enough space on MEGA...\n";
		print "I need to remove older backups\n";
		print "[ WARNING ] Removing: $oldestBKC";
		`megarm $oldestBKC`;
		print "Removed: $oldestBKC";
		# sleep(10);

	}
}

sub uploadOnMega {
	
	`megaput --path /Root/sf-backup $cfg{'TMP_BACKUP'}/$archive_file`;

}


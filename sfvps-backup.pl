#!/usr/bin/perl

use warnings;
use strict;

#
#	Main script performing test and backups, it manages to log
#	on proper files an handles notifications alerting admins. 
#

use Config::Simple;
use Capture::Tiny 'capture_merged';
use FindBin;

# *** SUB-ROUTINE *** #

sub load_cfg; 
sub perform_tests;
sub perform_backup;

# *** *** *** *** *** #

# *** GLOBAL VARS *** #

my $abs_path = $FindBin::RealBin.'/';
my $status = 0;
my %cfg;

# *** *** *** *** *** #

main();

sub main { 

    load_cfg;
    perform_tests;
	perform_backup;
	exit $status
}

sub load_cfg {

  Config::Simple->import_from("/root/.backupcfg",\%cfg);
  $cfg{"FOLDERS_TO_BACKUP"} = [split / /, $cfg{"FOLDERS_TO_BACKUP"}];

}

sub perform_tests {

  open LOGF, ">>$cfg{'TEST_LOG_FILE'}" or die "Could not open the log file: $!\n";

    print LOGF "\n\n\t************** #### **************\n";
    print LOGF "STARTING NEW BACKUP TEST:".localtime()."\n";
    print LOGF "\t************** #### **************\n";
    print LOGF capture_merged { system($^X,$abs_path."tests/config_files_test.pl")};
    print LOGF "\n\n\t************** #### **************\n";
    print LOGF "FINISHED BACKUP TEST:".localtime()."\n";
    print LOGF "\t************** #### **************\n\n";

  close LOGF or die "Could not close the log file: $!\n";

  if ($? != 0){

    print "\nErrors encountered while performing tests, exit.\n";
    system($^X,$abs_path."utils/PerlEmail.pl");
    $status = 5;

  } else {

    print "All test passed succesfully! You can proceed with a safe backup.\n";
    $status = 0;

  }

}


sub perform_backup {

  open LOGF, ">>$cfg{'LOG_FILE'}" or die "Could not open the log file: $!\n";

    print LOGF "\n\n\t************** #### **************\n";
    print LOGF "STARTING NEW BACKUP: ".localtime()."\n";
    print LOGF "\t************** #### **************\n";
    print LOGF capture_merged { system($^X,$abs_path."backup/backup.pl")};
    print LOGF "\n\n\t************** #### **************\n";
    print LOGF "FINISHED BACKUP: ".localtime()."\n";
    print LOGF "\t************** #### **************\n\n";

  close LOGF or die "Could not close the log file: $!\n";
	
  if ($? != 0){

    print "\nErrors encountered while performing backups, exit.\n";
    system($^X,$abs_path."utils/PerlEmail.pl");
    $status = 5;

  } else {

    print "Backup completed succesfully!\n";
    $status = 0;

  }

}

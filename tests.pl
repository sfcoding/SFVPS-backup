#!/usr/bin/perl

use warnings;
use strict;

use Config::Simple;
use Capture::Tiny 'capture_merged';
use FindBin;

# *** SUB-ROUTINE *** #

sub load_cfg; 
sub perform_tests;

# *** *** *** *** *** #

# *** GLOBAL VARS *** #

my $abs_path = $FindBin::RealBin.'/';
my $actual_time = localtime();
my %cfg;

# *** *** *** *** *** #

main();

sub main { 

    load_cfg;
    perform_tests;

}

sub load_cfg {

  Config::Simple->import_from("/root/.backupcfg",\%cfg);
  $cfg{"FOLDERS_TO_BACKUP"} = [split / /, $cfg{"FOLDERS_TO_BACKUP"}];

}

sub perform_tests {

  open LOGF, ">>$cfg{'TEST_LOG_FILE'}" or die "Could not open the log file: $!\n";

    print LOGF "\n\n\t************** #### **************\n";
    print LOGF "STARTING NEW BACKUP TEST: $actual_time\n";
    print LOGF "\t************** #### **************\n";
    print LOGF capture_merged { system($^X,$abs_path."tests/config_files_test.pl")};
    print LOGF "\n\n\t************** #### **************\n";
    $actual_time = localtime();
    print LOGF "FINISHED BACKUP TEST:".localtime()."\n";
    print LOGF "\t************** #### **************\n\n";

  close LOGF or die "Could not close the log file: $!\n";

  if ($?>>8 != 0){

    print "\nErrors encountered while performing tests, exit.\n";
    system($^X,$abs_path."utils/PerlEmail.pl");
    exit 5;

  } else {

    print "All test passed succesfully! You can proceed with a safe backup.\n";
    exit 0;

  }
}

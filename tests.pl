#!/usr/bin/perl

use warnings;
use strict;

use Config::Simple;
use Capture::Tiny 'capture_merged';
use FindBin;


my $abs_path = $FindBin::RealBin.'/';

#sub load_cfg; 
sub perform_tests;

# Launches Tests on configuration files;
my $actual_time = localtime();
#print $_,"\n" for %cfg;
#print $_,"\n" for @{$cfg{"FOLDERS_TO_BACKUP"}};

perform_tests;

my %cfg;

#load_cfg;

#sub load_cfg {
#  Config::Simple->import_from(".backupcfg",\%cfg);
#  $cfg{"FOLDERS_TO_BACKUP"} = [split / /, $cfg{"FOLDERS_TO_BACKUP"}];
#}

sub perform_tests {

  open LOGF, ">>/var/log/backup-mega-test.log" or die "Could not open the log file: $!\n";
    print LOGF "\n\n\t************** #### **************\n";
    print LOGF "STARTING NEW BACKUP TEST: $actual_time\n";
    print LOGF "\t************** #### **************\n";
    print LOGF capture_merged { system("perl",$abs_path."tests/config_files_test.pl")};
    print LOGF "\n\n\t************** #### **************\n";
    print LOGF "FINISHED BACKUP TEST: $actual_time\n";
    print LOGF "\t************** #### **************\n\n";

  close LOGF or die "Could not close the log file: $!\n";

  if ($?>>8 != 0){
    print "\nErrors encountered while performing tests, exit.\n";
    system("perl",$abs_path."utils/PerlEmail.pl");
    exit 5;
  } else {
    print "All test passed succesfully! You can proceed with a safe backup.\n"
  }
}

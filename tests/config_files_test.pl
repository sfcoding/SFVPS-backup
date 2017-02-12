#!/usr/bin/perl

use warnings;
use strict;
use Config::Simple;
use FindBin;
use Test::More tests => 2;

sub test_parameters_names; sub test_file_existence; sub test_syntax; 
sub test_paths_existence; sub load_cfg; sub test_mysql_config; 

my @required_pars = qw/TMP_BACKUP LOG_FILE ENCRYPT_KEY FOLDERS_TO_BACKUP/;
my $cfile = "../.backupcfg";
my $abs_path = $FindBin::RealBin.'/';
my %cfg;

# push the path of tests modules
push @INC, $abs_path."tests";

# import testing modules
require MySql::Test;
require MEGA::Test;


my $cfg_exist = ok(test_file_existence($abs_path.$cfile), "Config file existence");
subtest 'Config File Test'  => sub {
    plan 'skip_all' unless $cfg_exist;
    load_cfg $abs_path.$cfile, \%cfg if $cfg_exist;
    ok(test_parameters_names( \%cfg,\@required_pars),'Check Parameters Names');
    ok(test_syntax(\%cfg),"Syntax Check");
    ok(test_paths_existence(\%cfg),'Paths Verification'); 

    my $rootcpath = $cfg{"ROOT_CONFIG"};
    my $proceed = ok(test_file_existence($cfg{"ROOT_CONFIG"}),"Root Config Existence");
    load_cfg ($cfg{"ROOT_CONFIG"}, \%cfg) if $proceed;
    
    ok(MEGA::Test::test_mega(), "Connection to mega.nz");
    test_mysql_config(\%cfg);
};

exit 0;




############################################################################################
######################################### SUB-ROUTINES #####################################
############################################################################################


# Tests if the configuration file exists and is on the proper folder
sub test_file_existence {
  my $abs_path = shift or die;
  if (-e $abs_path){
    #print "Configuration file exists, ===>>> TEST PASSED!\n";
    return "true";
  } else {
    print ".backupcfg file does not exists or misplaced, TEST NOT PASSED!\n";
    return "false";
  }
}



# Tests if all required parameter names are on the .backupcfg file
sub test_parameters_names {
    my %cfg = %{+shift} or die;
    my @required_pars = @{+shift} or die;
    for my $par (@required_pars){
        if (!exists $cfg{$par}) {
            print "Missing configuration for $par in .backupconf, TEST NOT PASSED!\n";
            return "false";
        }
        #print "Parameter name: $par is .... OK!\n";
    }
    #print "Parameters names ok, ===>>> TEST PASSED!\n"
    return "true";
}



# Mostly Useless
sub test_syntax {
    my %cfg = %{+shift};
    $cfg{"FOLDERS_TO_BACKUP"} = [split / /, $cfg{"FOLDERS_TO_BACKUP"}];
    my @array_of_paths = @{delete $cfg{"FOLDERS_TO_BACKUP"}};
    $cfg{$_} = $_ for @array_of_paths;

    while (my($key, $val) = each %cfg) {
        if ($val !~ m#^(/\w+)(/\S+)*$#) {
            print "'$val' is a malformed path for key $key\n";
            return "false";
        }
    }
    return "true";
}



# Checks if the paths to file and folders exist
sub test_paths_existence {
    my %cfg = %{+shift};
    $cfg{"FOLDERS_TO_BACKUP"} = [split / /, $cfg{"FOLDERS_TO_BACKUP"}];
    my @array_of_paths = @{delete $cfg{"FOLDERS_TO_BACKUP"}};
    push @array_of_paths, (values %cfg);
    print @array_of_paths;
    for (@array_of_paths){
        if (!-d $_ and !-e $_){
            print "path '$_' does not exists, TEST NOT PASSED!\n";
            return "false";
        }
    #print "Path $_ exists .... OK!\n"
    }
    #print "All paths exist, ===>>> TEST PASSED!\n";
    return "true";
}


# Loads the configuration file
sub load_cfg {
    my $cfgpath = shift;
    Config::Simple->import_from($cfgpath,\%cfg);
}


#Testing for MySQL config file and connection
sub test_mysql_config {
my %cfg = %{+shift};
    if (!exists $cfg{'MYSQL_PWD'}){
        print "WARNING\n";
        print "MYSQL_PWD paramater missing, are you sure you do not need a password?\n";
    }
    ok(MySql::Test::test_query($cfg{'MYSQL_PWD'}),"Connection and Query MySql");
    }


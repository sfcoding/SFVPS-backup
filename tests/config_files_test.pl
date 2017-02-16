#!/usr/bin/perl

use warnings;
use strict;

use Config::Simple;
use FindBin;
use Test::More tests => 2;

# import testing modules

my $abs_path = $FindBin::RealBin.'/';
# push the path of tests modules
push @INC, $abs_path;

require MySql::Test;
require MEGA::Test;

# *** SUB-ROUTINE *** #

sub test_parameters_names; 	sub test_syntax; 	sub test_file_existence; 
sub test_paths_existence; 	sub load_cfg; 		sub test_mysql_config; 

# *** *** *** *** *** #

# *** GLOBAL VARS *** #

my %cfg;

my @required_pars = qw/TMP_BACKUP LOG_FILE ENCRYPT_KEY FOLDERS_TO_BACKUP/;
my $rootConfigFilePath = "/root/.backupcfg";

# *** *** *** *** *** #



my $cfg_exist = is(test_file_existence($rootConfigFilePath),1, "Config file existence");

subtest 'Config File Test'  => sub {
    
    plan 'skip_all' unless $cfg_exist;
    load_cfg $rootConfigFilePath, \%cfg if $cfg_exist;
    
    is(test_parameters_names( \%cfg,\@required_pars),1,'Check Parameters Names');
    
    my $pwd = delete $cfg{"MYSQL_PWD"};  

    is(test_syntax(\%cfg),1,"Paths Syntax Check");
    is(test_paths_existence(\%cfg),1,'Paths Verification'); 

    $cfg{"MYSQL_PWD"} = $pwd; 

    # my $rootcpath = $cfg{"ROOT_CONFIG"};
    # my $proceed = ok(test_file_existence($cfg{"ROOT_CONFIG"}),"Root Config Existence");
    # load_cfg ($cfg{"ROOT_CONFIG"}, \%cfg) if $proceed;
    
    ok(MEGA::Test::test_mega(), "Connection to mega.nz");
    test_mysql_config(\%cfg);
};

exit 0;


############################################################################################
######################################### SUB-ROUTINES #####################################
############################################################################################


# Tests if the passed file exists and is a plain file.
sub test_file_existence {

    my $abs_path = shift or die;

    return 1 if ( -f $abs_path);
    return 0;
}


# Tests if all required parameter names are on the .backupcfg file
sub test_parameters_names {
    my %cfg = %{+shift} or die;
    my @required_pars = @{+shift} or die;
    for my $par (@required_pars){
        if (!exists $cfg{$par}) {
            print "Missing configuration for $par in .backupconf, TEST NOT PASSED!\n";
            return 0;
        }
    }
    return 1;
}


# Mostly Useless
sub test_syntax {
    my %cfg = %{+shift};
    $cfg{"FOLDERS_TO_BACKUP"} = [split / /, $cfg{"FOLDERS_TO_BACKUP"}];
    my @array_of_paths = @{delete $cfg{"FOLDERS_TO_BACKUP"}};
    $cfg{$_} = $_ for @array_of_paths;

    while (my($key, $val) = each %cfg) {
        if ($val !~ m#^(/\w+)(/\S+)*$#) {  
            print "'$val' is a malformed absolute path for key $key\n";
            return 0;
        }
    }
    return 1;
}


# Checks if the paths to file and folders exist
sub test_paths_existence {
    my %cfg = %{+shift};
    $cfg{"FOLDERS_TO_BACKUP"} = [split / /, $cfg{"FOLDERS_TO_BACKUP"}];
    my @array_of_paths = @{delete $cfg{"FOLDERS_TO_BACKUP"}};
    delete $cfg{"LOG_FILE"};
    delete $cfg{"TEST_LOG_FILE"};
    push @array_of_paths, (values %cfg);
    # print @array_of_paths;
    for (@array_of_paths){
        if (!-e $_){
            print "path '$_' does not exists, TEST NOT PASSED!\n";
            return 0;
        }
    }
    return 1;
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


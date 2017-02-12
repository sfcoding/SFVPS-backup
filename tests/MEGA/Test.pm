#!/usr/bin/perl
package MEGA::Test;

use strict;
use warnings;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(test_mega);

sub test_mega {
    
    system("megadf --no-ask-password >> /dev/null");
    if ($?==0) {
        return 1;
    } else {
        return 0;
    } 
}

return "true";

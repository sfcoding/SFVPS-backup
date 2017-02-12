#!/usr/bin/perl

use warnings;
use strict;


my $to = 'andreagalloni92@gmail.com,lucarin91@gmail.com,andrea.galloni@studenti.unitn.it';
my $from = 'no-reply@sfcoding.com';
my $subject = '[SFvps] BACKUP TESTS FAILED';
my $message =  
"This message was sent to notify the System Admin.

Possibly some tests about backups on MEGA have failed :(

Please check /var/log/backup-mega-test.log on the vps for further details.\n\n
Cheers\n";
 
open(MAIL, "|/usr/sbin/sendmail -t");
 
# Email Header
print MAIL "To: $to\n";
print MAIL "From: $from\n";
print MAIL "Subject: $subject\n\n";
# Email Body
print MAIL $message;

close(MAIL);
print "Admin Email Sent Successfully\n";

#!/usr/bin/perl

#
#	This perl script is supposed to send an email to System Administrators
#	whenever something goes wrong with backup tests. 
#	the mail addresses list is loaded from: "/root/.mailbotrc"
#
#	Details about the config file can be found at the bottom of this file.
#
#	@Author: Andrea Galloni
#	@E-Mail: andreagalloni92[aaatttt]gmail[doooottt]com		
#	@License: No-License and NO WARRANTY.
#


use warnings;
use strict;


sub load_email_addresses; sub sendmail; sub main;

my $cfile = "/root/.mailbotrc";
my $logfiletests = "/var/log/backup-mega-test.log";
my $logfile = "/var/log/backup-mega.log";
my $to; # my $to = 'address1@gmail.com,address2@gmail.com,address3@gmail.it';

my %dest;
my $name;

main;

sub main {

	load_email_addresses;

	for (keys %dest) {

		$name = $_;
		$to = $dest{$_};
		sendmail;

	} 
}


sub load_email_addresses {

	open CFILE, "<$cfile" or die "Could not open config file$!";
	
	while (<CFILE>) {

		if ($_ !~ /^\s*#/) {
			my @fields = split /:/ ;
			$dest{$fields[0]} = $fields[1];		
		}
		
	}

	close CFILE or die "Could not close config file$!";
	
}



sub sendmail {

	my $testlogs = `tail -50 $logfiletests`;
        my $bcklogs = `tail -50 $logfile`;

	my $from = 'no-reply@sfcoding.com';
	my $subject = '[SFvps] BACKUP ISSUES';

	my $message =  
	"Hi $name! This message was sent to notify the System Admin.\n\n
	Possibly something with tests or the actual script about backups on MEGA have failed :(\n\n
	Please check /var/log/backup-mega-test.log and /var/log/backup-mega.log on the vps for further details.\n\n
	Cheers\n\n P.s.: hereby an extract of the logs\n\n$testlogs\n\n$bcklogs";
	 
	open(MAIL, "|/usr/sbin/sendmail -t");
	 
	# Email Header
	print MAIL "To: $to\n";
	print MAIL "From: $from\n";
	print MAIL "Subject: $subject\n\n";

	# Email Body
	print MAIL $message;

	close(MAIL);
	print "Admin Email Sent Successfully\n";

}


#
#	The configuration file has to be placed at: "/root/.mailbotrc"
#	the file have to be compliant to the following schema:
#		
#		# lines STARTING with hash will be ignored  
#
#		AdminFirstName:email@address.smth
#
#		e.g.: 
#
#		# this is a config file and this is a comment
#		Andrea:andrea@gmail.com
#		Luca:luca@gmail.com
#

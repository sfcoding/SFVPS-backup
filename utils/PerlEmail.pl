#!/usr/bin/perl

use warnings;
use strict;

sub load_email_addresses; sub sendmail; sub main;

my $cfile = "/root/.mailbotrc";
my $logfile = "/var/log/backup-mega-test.log";
my $to # my $to = 'address1@gmail.com,address2@gmail.com,address3@gmail.it';

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
	
	# print "$_ : $dest{$_}\n" for (keys %dest);

}



sub sendmail {

	my $logs = `tail -50 $logfile`;

	my $from = 'no-reply@sfcoding.com';
	my $subject = '[SFvps] BACKUP TESTS FAILED';
	my $message =  
	"Hi $name! This message was sent to notify the System Admin.\n\n
	Possibly some tests about backups on MEGA have failed :(\n\n
	Please check /var/log/backup-mega-test.log on the vps for further details.\n\n
	Cheers\n\n P.s.: hereby an extract of the log\n\n$logs";
	 
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

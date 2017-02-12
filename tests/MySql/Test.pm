#!/usr/bin/perl

package MySql::Test;

use strict;
use warnings;
use DBI;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(test_query);


sub test_query {

	## mysql user database name
	my $db ="mysql";
	## mysql database user name
	my $user = "root";
	## mysql database password
	my $pass = shift;
	## hostname
	my $host="localhost";

	## SQL query
	my $query = "show tables";

	my $dbh = DBI->connect("DBI:mysql:$db:$host", $user, $pass) 
        or print "Impossible to connect to the database.$!\n" and return 0;
	
    my $sqlQuery  = $dbh->prepare($query)
        or print "Can't prepare $query: $dbh->errstr\n" and return 0;

	my $rv = $sqlQuery->execute
        or print "can't execute the query: $sqlQuery->errstr" and return 0;

  	#print "****************| MySQL Query Test |*******************\n";
	#print "Here is a list of tables in the MySQL database '$db':\n\n";

	#while (my @row= $sqlQuery->fetchrow_array()) {
	#  my $tables = $row[0];
	#  print "$tables\n";
	#}

	my $rc = $sqlQuery->finish;
	$dbh->disconnect;
	return 1;
}

return "true";

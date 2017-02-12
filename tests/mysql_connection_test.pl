#!/usr/bin/perl

use DBI;
use strict;
use warnings;


## mysql user database name
my $db ="mysql";
## mysql database user name
my $user = "root";
## mysql database password
my $pass = shift @ARGV;
## hostname
my $host="localhost";

## SQL query
my $query = "show tables";
my $dbh = DBI->connect("DBI:mysql:$db:$host", $user, $pass) or die "Impossible to connect to the database.\n";
my $sqlQuery  = $dbh->prepare($query)
  or die "Can't prepare $query: $dbh->errstr\n";

my $rv = $sqlQuery->execute
  or die "can't execute the query: $sqlQuery->errstr";

print "****************| MySQL Query Test |*******************\n";
print "Here is a list of tables in the MySQL database '$db':\n\n";

while (my @row= $sqlQuery->fetchrow_array()) {
  my $tables = $row[0];
  print "$tables\n";
}

my $rc = $sqlQuery->finish;
$dbh->disconnect;

exit(0);

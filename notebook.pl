#!/usr/bin/perl -w
## Mynotebook ver.1.1
## by Xspeed, 2010.

use Fcntl;
my $DBfile = $ARGV[0] || './mynotes.txt';
if (-e $DBfile) { die qq('$DBfile' is not a text file. Quit.\n) unless -T $DBfile; }
my $color = "\033[1;33m"; #yellow
my $col_end = "\033[0m";
my %Commands = qw(	add a
					find f
					show s
					remove r
				);
my $Notes;
sysopen(DB, $DBfile, O_RDWR|O_CREAT, 0600) || die "Can't open DB: $!\n";
$Notes = () = <DB>;
close DB;

print "-= My notebook =-\n";
print '* ',`date`;
print '* Editing: ', "$DBfile\n";
print '* Notes: ', "$Notes\n";
print CommandsList();

while (($_=<STDIN>) !~ /^\s*$/) {
	chomp;
	if (/^$Commands{'add'}\s+?(.+)$/) {
		open (DB, '>>', $DBfile) || die "Can't open DB: $!\n";
		print DB "$1\n";
		close DB;
	}
	elsif (/^$Commands{'find'}\s+?(.+)$/) {
		my $term = $1;
		open (DB, $DBfile) || die "Can't open DB: $!\n";
		while (<DB>) {
			if (/$term/i) {
				print ":$. $`", $color, $&, $col_end, $';
			}
		}
		close DB;
	}
	elsif (/^$Commands{'show'}\s*$/) {
		open (DB, $DBfile) || die "Can't open DB: $!\n";
		print "$. $_" while <DB>;
		close DB;
	}
	elsif (/^$Commands{'remove'}\s+?(\d+)$/) {
		my $n = $1;
		open (DB, $DBfile) || die "Can't open DB: $!\n";
		my @tmp = <DB>;
		close DB;
		open (DB, '>', $DBfile) || die "Can't open DB: $!\n";
		delete $tmp[$n-1] || print "(!) Wrong note number: # ${n}\n";
		for (@tmp) { print DB if defined; }
		close DB;
		undef @tmp;
	}
	else {
		print "(!) Wrong command: $_\n";
	}
	print CommandsList();
}

sub CommandsList {
	my $output;
	while(my($a,$b) = each %Commands) {
		 $output .= "$a => $b\; ";
	}
	substr($output,-2) = ' ';
	return "$output: ";
}

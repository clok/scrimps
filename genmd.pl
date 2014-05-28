#! /usr/bin/env perl

use strict;
use warnings;
use Getopt::Std;
my %opts;
getopts('dpoh', \%opts);

my $track;

my @pm = `find . -name "*.pm"`;

print STDOUT "Inspect mode: \n" if !exists $opts{p};
print STDOUT "Process mode: \n" if exists $opts{p};

foreach my $f (@pm) {
	chomp $f;
	next if ! -e $f;
	my $dir = ($f =~ /^(.+)\/\w+\.pm/, $1);
	my @pkgs = `grep '\^package' $f`;
	my $name;

	if (defined $pkgs[0]) {
		$name = $pkgs[0];
	} else {
		$name = `grep '\^package' $f`;
	}

	die "Name not defined $f" if ! defined $name;

	$name =~ s/package\s+//;
	$name =~ s/;//;
	chomp $name;

	if (!exists $opts{p}) {
		print STDOUT "- ".$name."\n";
		if (exists $opts{d}) {
			print join(" | ", $f, $name)."\n";
		}
		next;
	}

	print STDOUT "Processing: ".$name."... ";

	my $readme = $dir."/README.md";

	if (exists $opts{o}) {
		if (!exists $track->{$readme}) {
			if (-e $readme) {
				print STDOUT " moving existing README.md to ".$readme.".BAK... ";
				system('mv '.$readme.' '.$readme.'.BAK');
				$track->{$readme}++;
			}
		}
	} else {
		if (-e $readme) {
			print STDOUT " README.md already exists.\n";
			next;
		}
	}

	my $dox = `pod2markdown $f`;
	if ($dox =~ /^$/) {
		print STDOUT "No POD to convert.\n";
		next;
	}

	open my $fh, ">>", $readme;
	print $fh $name."\n";
	for (1..length($name)) {
		print $fh "-";
	}
	print $fh "\n";
	print $fh $dox."\n";
	close $fh;

	$track->{$readme}++;

	print STDOUT "Done\n";
}


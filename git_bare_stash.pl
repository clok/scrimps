#! /usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;
use Data::Dumper;

my %opts;

# Options
getopts( 'm:r:b:adcnph', \%opts );

if ( exists $opts{h} ) {
  print " ./gitadds.pl -m <> -r <> -b <> -[adcnph]

Options:
--------
 -m <Commit Message>
 -r <remote repo>
 -b <branch>
 -a Add modified files
 -d Remove Deleted Files
 -n Add New Files
 -c Commit Changes
 -p push
 -h Display this help
";
  exit;
}

my @branches;

for my $ln (`git branch -a`) {
  chomp $ln;
  my $branch = ( $ln =~ /(\s{2}|\*\s)(.+)$/, $2 );

  #print $ln. " : " . $branch . "\n";
  push @branches, $branch;
}

print "Branches to process: " . scalar(@branches) . "\n";

# push to remote origin
for my $br (@branches) {
  my $cmd = 'git checkout ' . $br;
  print "executing: " . $cmd . "\n";
  system($cmd);

  $cmd = 'git push -u origin ' . $br;
  print "executing: " . $cmd . "\n";
  system($cmd);
}

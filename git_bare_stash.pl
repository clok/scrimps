#! /usr/bin/env perl

use strict;
use warnings;

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

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

my @gitinfo = `git status -s`;

my $go       = 0;
my $unmerged = 0;

my ( @mod, @del, @new, @unm, $staged );

for my $ln (@gitinfo) {
  chomp $ln;
  my @flags = split( //, substr( $ln, 0, 2 ) );
  my $file = substr( $ln, 3, length $ln ) . "\n";
  chomp $file;

  if ( $flags[0] ne ' ' && $flags[0] ne '?' ) {
    $staged->{total}++;
    if ( $flags[0] eq 'M' ) {
      push @{ $staged->{mod} }, $file;
    }
    elsif ( $flags[0] eq 'D' ) {
      push @{ $staged->{del} }, $file;
    }
    elsif ( $flags[0] eq 'A' ) {
      push @{ $staged->{new} }, $file;
    }
    elsif ( $flags[0] eq 'U' ) {
      # do nothing
    }
    else {
      print "WARN: Unknown switch flag ($flags[1]) for file: $file\n";
    }
  }

  if ( $flags[1] ne ' ' ) {
    if ( $flags[1] eq 'M' ) {
      push @mod, $file;
    }
    elsif ( $flags[1] eq 'D' ) {
      push @del, $file;
    }
    elsif ( $flags[1] eq '?' ) {
      push @new, $file;
    }
    elsif ( $flags[1] eq 'U' ) {
      push @unm, $file;
    }
    else {
      print "WARN: Unknown switch flag ($flags[1]) for file: $file\n";
    }
  }
}

print "Files Modified: " . scalar(@mod) . "\n git add ";
foreach (@mod) {
  print $_. " ";
}
print "\n\nFiles Deleted: " . scalar(@del) . "\n git rm ";
foreach (@del) {
  print $_. " ";
}
print "\n\nNew Files: " . scalar(@new) . "\n git add ";
foreach (@new) {
  print $_. " ";
}
if ( scalar @unm ) {
  print "\n\nUnmegred Files: " . scalar(@unm) . "\n ";
  foreach (@unm) {
    print $_. " ";
  }
}
print "\n\n";

if ( $staged->{total} ) {
  print "Files Staged for Commit: " . $staged->{total} . "\n";
  print " -- Modified: " . ( join( ' ', @{ $staged->{mod} } ) ) . "\n"
    if exists $staged->{mod};
  print " -- Deleted: " . ( join( ' ', @{ $staged->{del} } ) ) . "\n"
    if exists $staged->{del};
  print " -- New: " . ( join( ' ', @{ $staged->{new} } ) ) . "\n"
    if exists $staged->{new};
  print "\n";
}
else {
  print "No files staged for commit.\n\n";
}

if ( exists $opts{a} ) {
  print "Adding modified files...";
  my $f = '';
  foreach (@mod) {
    $f .= $_ . " ";
  }
  system( 'git add ' . $f );
  print "\n";
}

if ( exists $opts{n} ) {
  print "Adding new files...\n";
  my $f = '';
  foreach (@new) {
    $f .= $_ . " ";
  }
  system( 'git add ' . $f );
  print "\n";
}

if ( exists $opts{d} ) {
  print "Removing deleted files...\n";
  my $f = '';
  foreach (@del) {
    $f .= $_ . " ";
  }
  system( 'git rm ' . $f );
  print "\n";
}

if ( exists $opts{c} ) {
  print "\nCommiting changes...\n";
  if ( !exists $opts{m} ) {
    $opts{m} = "Auto-Commit " . localtime;
  }
  print " - Using commit message: " . $opts{m} . "\n\n";
  system( 'git commit -m "' . $opts{m} . '"' );
}

if ( exists $opts{p} ) {
  print "\nPushing changes...\n";
  if ( !exists $opts{r} ) {
    $opts{r} = "origin";
  }
  if ( !exists $opts{b} ) {
    my @gitbranch = `git branch`;
    foreach (@gitbranch) {
      if ( $_ =~ /^\*\s(.*)$/ ) {
        $opts{b} = $1;
      }
    }
  }
  print " - Using Remote: " . $opts{r} . "\n";
  print " - Using Branch: " . $opts{b} . "\n";
  print 'git push -u ' . $opts{r} . ' ' . $opts{b} . "\n\n";
  system( 'git push -u ' . $opts{r} . ' ' . $opts{b} );
}

#! /usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;

my %opts;
# Options
getopts('m:r:b:adcnph', \%opts);

if (exists $opts{h}) {
	print " ./autoGit.pl -m <> -r <> -b <> -[adcnph]

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

my @gitinfo = `git status`;

my $go = 0;
my $unmerged = 0;

my (@mod, @del, @new, @unm);

foreach my $ln (@gitinfo) {
   if ($ln =~ /Changes not staged for commit:/
		 || $ln =~ /Changed but not updated/
		 || $ln =~ /^#\sUntracked/
	 ) {
      $go = 1;
   }
   if ($go == 1) {
      if ($ln =~ /\smodified:\s+(.+)$/) {
			push @mod, $1;
      } elsif ($ln =~ /\sdeleted:\s+(.+)$/) {
			push @del, $1;
      } elsif ($ln =~ /^#\t(.+)$/) {
			push @new, $1;
      }
   }
	if ($ln =~ /Unmerged paths:/) {
		$unmerged = 1;
	}
	if ($unmerged == 1) {
		if ($ln =~ /\smodified:\s+(.+)$/) {
			push @unm, $1;
		}
	}
}

print "Files Modified: ".scalar(@mod)."\n git add ";
foreach (@mod) {
   print $_." ";
}
print "\n\nFiles Deleted: ".scalar(@del)."\n git rm ";
foreach (@del) {
   print $_." ";
}
print "\n\nNew Files: ".scalar(@new)."\n git add ";
foreach (@new) {
   print $_." ";
}
if (scalar @unm > 0) {
	print "\n\nUnmegred Files: ".scalar(@unm)."\n ";
	foreach (@unm) {
		print $_." ";
	}
}
print "\n\n";

if (exists $opts{a}) {
	print "Adding modified files...";
	my $f = '';
	foreach (@mod) {
		$f .= $_." ";
	}
	system('git add '.$f);
	print "\n";
}

if (exists $opts{n}) {
	print "Adding new files...\n";
	my $f = '';
	foreach (@new) {
		$f .= $_." ";
	}
	system('git add '.$f);
	print "\n";
}

if (exists $opts{d}) {
	print "Removing deleted files...\n";
	my $f = '';
	foreach (@del) {
		$f .= $_." ";
	}
	system('git rm '.$f);
	print "\n";
}

if (exists $opts{c}) {
	print "\nCommiting changes...\n";
	if (!exists $opts{m}) {
		$opts{m} = "Auto-Commit ".localtime;
	}
	print " - Using commit message: ".$opts{m}."\n\n";
	system('git commit -m "'.$opts{m}.'"');
}

if (exists $opts{p}) {
	print "\nPushing changes...\n";
	if (!exists $opts{r}) {
		$opts{r} = "origin";
	}
	if (!exists $opts{b}) {
		my @gitbranch = `git branch`;
		foreach (@gitbranch) {
			if ($_ =~ /^\*\s(\w+)$/) {
				$opts{b} = $1;
			}
		}
	}
	print " - Using Remote: ".$opts{r}."\n";
	print " - Using Branch: ".$opts{b}."\n";
	print 'git push -u '.$opts{r}.' '.$opts{b}."\n\n";
	system('git push -u '.$opts{r}.' '.$opts{b});
}

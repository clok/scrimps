#! /usr/bin/env perl

use strict;
use warnings;

# Default modules
use Getopt::Std;
use YAML::Tiny;
use JSON;

my %opts;
# Options
# -y <yaml input for shamap>
# -o <output location>
# -h display help
getopts('j:y:hD', \%opts);

if (!exists $opts{y} || exists $opts{h}) {
   print "./test.pl -j <>

Options
 -y <yaml input for shamap>
 -o <output location>
 -h display help
";
exit;
}

if (!exists $opts{o}) {
   $opts{o} = './con_yaml.json';
}

print STDERR "Converted file will be: $opts{o}\n";

#-----------------------------------------------------------------------------
# MAIN Block
#-----------------------------------------------------------------------------
MAIN: {
   if (exists $opts{y}) {
      print STDERR "Loading YAML file $opts{y}\n";
      my $yaml = YAML::Tiny->new;
      $yaml = YAML::Tiny->read($opts{y});

      open CONV, ">", $opts{o} || die "Couldn't open $opts{o} for write.\n";
      print CONV encode_json($yaml->[0]);
      close CONV;

      print STDERR "Conversion Complete\n";
   }
}

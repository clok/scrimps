#! /usr/bin/env perl

use strict;
use warnings;

use Net::DNS;
use Data::Dumper;

my $url = $ARGV[0];

my $res   = Net::DNS::Resolver->new;
my $query = $res->search($url);

if ($query) {
   foreach my $rr ( $query->answer ) {
      next unless $rr->type eq "A";
      print "A Record IP: ".$rr->address, "\n";
   }
}
else {
   warn "IP query failed: ", $res->errorstring, "\n";
}

$query = $res->query($url, "NS");

if ($query) {
	foreach my $rr (grep { $_->type eq 'NS' } $query->answer) {
		print "Nameserver: ".$rr->nsdname, "\n";
	}
}
else {
	warn "Nameserver query failed: ", $res->errorstring, "\n";
}

$query = $res->query($url, "MX");

if ($query) {
	foreach my $rr (grep { $_->type eq 'MX' } $query->answer) {
		print "MX-Record Exchange: ".$rr->exchange, "\n";
	}
}
else {
	warn "MX-Record query failed: ", $res->errorstring, "\n";
}

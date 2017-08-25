use strict;
use warnings;

use Data::Dumper;

use constant NEXT => 0;
use constant VALUE => 1;

$| = 1;

my $list = undef;
my $head = undef;
my $tail = \$head;
foreach (reverse 1..10) {
  $list = [ $list, $_ * $_];
}

print( "Dump of Linked List: " . Dumper($list) );

my $pos = 0;
while ($list) {
  my $val = $list->[VALUE];
  $list = $list->[NEXT];
  $pos++;
  print( "Square of " . $pos . " is " . $val . "\n" );
}

print( "Dump of Linked List: " . Dumper($list) );

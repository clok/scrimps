use strict;
use warnings;

use Data::Dumper;

$| = 1;

{
  # circular

  package circular;

  sub new {
    my ($class, $value, $square) = @_;
    my $self = { value=>$value, square=>$square };
    return bless $self, $class;
  }

  sub link {
    my $item = shift;
    return @_ ? ($item->{link} = shift) : $item->{link};
  }

  # more subs
}

my @items;
my $item = undef;
foreach (1..10) {
  my $new_item = new circular($_, $_ * $_);
  push @items, $new_item;
  if ($item) {
    $item->link($new_item);
    $items[-1]->link($items[0]);
  }
  $item = $new_item;
}

print( "Dump of Linked List: " . Dumper(\@items) );

foreach (@items) {
  print "Square of " . $_->{value} . " is " . $_->{square} . "\n";
}

my $init = $items[0];
my $current = undef;
my $first_pass = 1;
my $loops = 0;
while (1) {
  if ($first_pass) {
    $first_pass = 0;
    $current = $init;
  } else {
    if ($init->{value} == $current->{value}) {
      if ($loops == 3) {
        last;
      } else {
        $loops++;
      }
    }
  }

  print $current->{value}. "(" . $current->{square} . ") -> ";
  $current = $current->link;
}

print "\n";

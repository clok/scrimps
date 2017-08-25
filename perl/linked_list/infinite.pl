use strict;
use warnings;

use Data::Dumper;

$| = 1;

{
  # Infinite list
  package Infinite;

  ##
  # Core Fucntions
  sub new {
    my $self = shift;
    my $class = ref($self) || $self;
    my ($head, $tail) = @_;
    bless { head=>$head, tail=>$tail} => $class;
  }

  sub head {
    $_[0]{head};
  }

  sub tail {
    my $tail = $_[0]{tail};
    # If tail is a promise, execute it
    if (ref($tail) eq CODE) {
      $_[0]{tail} = &$tail;
    }
    $_[0]{tail};
  }

  sub empty {
    my $class = ref(shift()) || Infinite;
    bless {empty => q{yes}} => $class;
  }

  sub is_empty {
    exists $_[0]{empty}
  }
  #
  ##

  ##
  # Do the Math

  ## Compute f(n), f(n+1), f(n+2) ...
  sub tabulate {
    my $f = shift;
    my $n = shift;
    Infinite->new(&$f($n), sub { &tabulate($f, $n+1) });
  }

  ## Compute i, f(i), f(f(i)), f(f(f(i))), ...
  sub iterate {
    my $f = shift;
    my $i = shift;
    Infinite->new($i, sub { &iterate($f, &$f($i)) });
  }

  ## Compute list of first n elements of an infinite list.
  sub take {
    my $list = shift;
    my $n = shift;
    my @r;
    while ($n-- && !$list->is_empty) {
      push @r, $list->head;
      $list = $list->tail;
    }
    @r;
  }

  #
  ##

  ##
  # Tools

  #
  ##
}

{
  my $sq = double_head::->new("squares");
  my $cu = double_head::->new("cubes");
  my $three;

  for (my $i=0; $i<5; ++$i) {
    my $new = double::->new($i*$i);
    $sq->append($new);
    $sq->ldump;
    $new = double::->new($i*$i*$i);
    $cu->append($new);
    $cu->ldump;
    $three = $new if $i == 3;
  }

  $sq->append($cu->first->remove);
  $sq->prepend($cu->first->remove($three));

  $sq->ldump;
  $cu->ldump;
}

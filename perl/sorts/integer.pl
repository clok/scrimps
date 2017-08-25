use strict;
use warnings;

use Data::Dumper;

$| = 1;

# QuickSort
sub perl_sort {
  my $array = shift;

  return sort @$array;
}

sub perl_human {
  my $array = shift;
  return sort { $a <=> $b } @$array;
}

sub inplace_selection_sort {
  my $array = shift;

  my $i; # starting index
  my $j; # running index

  # start from the end
  for ($i = 0; $i < $#$array; $i++) {
    my $m = $i; # index on min
    my $x = $array->[$m]; # min value

    for ($j = $i + 1; $j < $#$array; $j++) {
      ($m, $x) = ( $j, $array->[$j]) if $array->[$j] < $x;
    }

    # swap if needed
    @$array[$m, $i] = @$array[$i, $m] unless $m == $i;
  }

  print "test\n";
}

sub selection_sort {
  my $array = shift;
  my @clone = @$array;

  my $i; # starting index
  my $j; # running index

  # start from the end
  for ($i = 0; $i < $#clone; $i++) {
    my $m = $i; # index on min
    my $x = $clone[$m]; # min value

    for ($j = $i + 1; $j < $#clone; $j++) {
      ($m, $x) = ( $j, $clone[$j]) if $clone[$j] < $x;
    }

    # swap if needed
    @clone[$m, $i] = @clone[$i, $m] unless $m == $i;
  }

  return @clone;
}

sub inplace_bubble_sort {
  my $array = shift;

  my $i; # initial index
  my $j; # running index
  my $ncomp = 0; # number for comparison
  my $nswap = 0; # number for swaps

  # start from the end
  for ($i = $#$array; $i; $i--) {
    for ($j = 1; $j <= $i; $j++) {
      $ncomp++;
      # swap if needed
      if ($array->[$j - 1] > $array->[$j]) {
        @$array[$j, $j - 1] = @$array[$j - 1, $j];
        $nswap++
      }
    }
  }
  print "bubble_sort: ", scalar @$array, " elements, $ncomp comparisons, $nswap swaps\n";
}

sub bubble_sort {
  my $array = shift;
  my @clone = @$array;

  my $i; # initial index
  my $j; # running index
  my $ncomp = 0; # number for comparison
  my $nswap = 0; # number for swaps

  # start from the end
  for ($i = $#clone; $i; $i--) {
    for ($j = 1; $j <= $i; $j++) {
      $ncomp++;
      # swap if needed
      if ($clone[$j - 1] > $clone[$j]) {
        @clone[$j, $j - 1] = @clone[$j - 1, $j];
        $nswap++
      }
    }
  }
  #print "bubble_sort: ", scalar @clone, " elements, $ncomp comparisons, $nswap swaps\n";
  return @clone;
}

sub inplace_bubblesmart {
  my $array = shift;
  my $start = 0;
  my $ncomp = 0;
  my $nswap = 0;

  my $i = $#$array;
  print "I: $i\n";

  while (1) {
    my $new_start;
    my $new_end = 0;

    my $j;
    for ($j = $start, $j <= $i, $j++) {
      $ncomp++;
      if ($array->[$j - 1] > $array->[$j]) {
        @$array[$j, $j - 1] = @$array[$j - 1, $j];
        $nswap++;
        $new_end = $j - 1;
        $new_start = $j - 1 unless defined $new_start;
      }
    }
    last unless defined $new_start;
    $i = $new_end;
    $start = $new_start;
  }
  print "bubblesmart: ", scalar @$array, " elements, $ncomp comparisons, $nswap swaps\n";
}

sub bubblesmart {
  my $array = shift;
  my @clone = @$array;
  my $start = 0;
  my $ncomp = 0;
  my $nswap = 0;

  my $i = $#clone;
  print "I: $i\n";

  while (1) {
    my $new_start;
    my $new_end = 0;

    my $j;
    for ($j = $start, $j <= $i, $j++) {
      $ncomp++;
      if ($clone[$j - 1] > $clone[$j]) {
        @clone[$j, $j - 1] = @clone[$j - 1, $j];
        $nswap++;
        $new_end = $j - 1;
        $new_start = $j - 1 unless defined $new_start;
      }
    }
    last unless defined $new_start;
    $i = $new_end;
    $start = $new_start;
  }
  print "bubblesmart: ", scalar @clone, " elements, $ncomp comparisons, $nswap swaps\n";
  return @clone;
}

sub inplace_counting_sort {
  my ($array, $max) = @_;
  my @counter = (0) x $max;
  foreach my $elem (@$array) { $counter[$elem]++ }
  return map { ($_) x $counter[$_] } 0..$max-1;
}

sub counting_sort {
  my ($array, $max) = @_;
  my @clone = @$array;
  my @counter = (0) x $max;
  foreach my $elem (@clone) { $counter[$elem]++ }
  return map { ($_) x $counter[$_] } 0..$max-1;
}

sub merge_sort {
  merge_sort_recurse $_[0], 0, $#{$_[0]}
}

sub merge_sort_recurse {
  my ($array, $first, $last) = @_;

  if ($last > $first) {
    local $^W = 0; # silence deep recursion warnings
    my $mid = int(($last + $first) / 2);

    merge_sort_recurse($array, $first, $mid);
    merge_sort_recurse($array, $mid + 1, $last);
    merge($array, $first, $mid, $last);
  }
}

sub merge {
  my ($array, $first, $mid, $last) = @_;

  my $n = $last - $first + 1;

}

{
  use Benchmark;
  use List::Util qw( min max );

  srand;

  my @array;

  for (1..1000) {
    push @array, int(rand(1000));
  }

  my $min = min(@array);
  my $max = max(@array);

  # print "\n\nhuman sort:\n";
  # my @v = perl_human(\@array);
  # print Dumper(\@v);
  #
  # print "\n\nselectiion sort:\n";
  # @v = selection_sort(\@array);
  # print Dumper(\@v);
  #
  # print "\n\nbubble_sort:\n";
  # @v = bubble_sort(\@array);
  # print Dumper(\@v);

  # print "\n\nbubblesmart:\n";
  # @v = bubblesmart(\@array);
  # print Dumper(\@v);

  # print "\n\ncounting sort:\n";
  # @v = counting_sort(\@array, $max);
  # print Dumper(\@v);

  timethese(100, {
    'selection'  => sub { selection_sort(\@array) },
    'counting'   => sub { counting_sort(\@array, $max) },
    'bubble_sort' => sub { bubble_sort(\@array) },
    #'bubblesmart' => 'my @a = @array; bubblesmart(\@a)'
  });

  timethese(100000, {
    'perl'       => sub { perl_sort(\@array) },
    'human'      => sub { perl_human(\@array) }
  })
}

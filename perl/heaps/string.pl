use strict;
use warnings;

use Data::Dumper;

$| = 1;

sub heapup {
  my ($array, $index) = @_;
  my $value = $array->[$index];

  while ($index) {
    my $parent = int( ($index-1)/2 );
    my $pv = $array->[$parent];

    # String compare
    last if $pv lt $value;

    $array->[$index] = $pv;
    $index = $parent;
  }
  $array->[$index] = $value;
}

sub heapdown {
  my ($array, $index, $last) = @_;
  defined($last) or $last = $#$array;

  # return if only one element
  return if $last <= 0;

  my $iv = $array->[$index];

  while ($index < $last) {
    my $child = 2*$index + 1;
    last if $child > $last;
    my $cv = $array->[$child];
    if ($child < $last) {
      my $cv2 = $array->[$child+1];
      # Sting compare
      if ($cv2 lt $cv) {
        $cv = $cv2;
        ++$child;
      }
    }
    last if $iv le $cv;
    $array->[$index] = $cv;
    $index = $child;
  }
  $array->[$index] = $iv;
}

sub heapify_array_up {
  my $array = shift;
  my $i;

  for ($i = 1; $i < $#$array; ++$i) {
    heapup($array, $i)
  }
}

sub heapify_array_down {
  my $array = shift;
  my $last = $#$array;
  my $i;

  for ($i = int( ($last-1)/2 ); $i >=0; --$i) {
    heapdown($array, $i, $last)
  }
}

sub extract {
  my $array = shift;
  my $last = shift || $#$array;

  # empty heap, this is bad
  return undef if $last < 0;

  # no cleanup if only one element in heap
  return pop(@$array) unless $last;

  # Get smallest value in heap
  my $val = $array->[0];

  # Replace smallest with the tail element and bubble it down the heap
  $array->[0] = pop(@$array);
  heapdown($array, 0);

  return $val;
}

sub heapify {
  my $array = shift;
  my $last = $#$array;
  my $i;

  for ($i = int( ($last-1)/2 ); $i >=0; --$i) {
    heapdown($array, $i, $last)
  }
}

{
  my @heap = qw(and brilling Twas the toves slithy);
  print Dumper(\@heap);
  heapify(\@heap);
  print Dumper(\@heap);

  push(@heap, 'A');
  heapup(\@heap, $#heap);
  print Dumper(\@heap);

  foreach (1..3) {
    my $val = extract(\@heap);
    print "Value: $val\n";
  }
  print Dumper(\@heap);
}

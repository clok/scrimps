#!/usr/bin/perl
#
# Stream.pm
#
# Sample implementation of lazy, infinite streams with memoization
#
# Copyright 1997 M-J. Dominus (mjd@pobox.com)
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of any of:
#       1. Version 2 of the GNU General Public License as published by
#          the Free Software Foundation;
#       2. Any later version of the GNU public license, or
#       3. The Perl `Artistic License'
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the Artistic License with this
#    Kit, in the file named "Artistic".  If not, I'll be glad to provide one.
#
#    You should also have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#


package Stream;

use Exporter;
@ISA = (Exporter);
@EXPORT = qw(new iterate tabulate upto iota filter
	     primes merge hamming stats rand list2stream
	     iterate_chop chop_if mingle squares_from hailstones);

### Basic functions

## Manufacture a new stream node with given head and tail.
sub new {
  my $what = shift;
  my $pack = ref($what) || $what;
  my ($h, $t) = @_;
  bless { h => $h, t => $t } => $pack;
}

## Return the head of a stream
sub head {
  $_[0]{h};
}

## return the tail of a stream, collecting on a promise
## if necessary
sub tail {
  my $t = $_[0]{t};
  if (ref $t eq CODE) {		# It is a promise
    $_[0]{t} = &$t;
  }
  $_[0]{t};
}

## Construct an empty stream
sub empty {
  my $pack = ref(shift()) || Stream;
  bless {e => q{Yes, I'm empty.}} => $pack;
}

## Is this stream the empty stream?
sub is_empty {
  exists $_[0]{e};
}

### Tools

## Compute f(n), f(n+1), f(n+2) ...
sub tabulate {
  my $f = shift;
  my $n = shift;
  Stream->new(&$f($n), sub { &tabulate($f, $n+1) });
}

## Compute i, f(i), f(f(i)), f(f(f(i))), ...
sub iterate {
  my $f = shift;
  my $i = shift;
  Stream->new($i, sub { &iterate($f, &$f($i)) });
}

## Compute list of first n elements of stream.
sub take {
  my $s = shift;
  my $n = shift;
  my @r;
  while ($n-- && !$s->is_empty) {
    push @r, $s->head;
    $s = $s->tail;
  }
  @r;
}

## Return new stream of elements of $s with first
## $n elements skipped.
sub drop {
  my $s = shift;
  my $n = shift;
  while ($n-- && !$s->is_empty) {
    $s = $s->tail;
  }
  $s;
}

## Actually modify $s to discard first $n elements.
## Return undef if $s was exhausted.
sub discard {
  my $s = shift;
  my $n = shift;
  my $d = $s->drop($n);
  if ($d->is_empty) {
    $s->{e} = q{Empty.};
    delete $s->{h};
    delete $s->{t};
  } else {
    $s->{h} = $d->{h};
    $s->{t} = $d->{t};
  }
  $s;
}

## Display first few elements of a stream
$SHOWLENGTH = 10;		# Default number of elements to show
sub show {
  my $s = shift;
  my $len = shift;
  my $showall = $len eq ALL;
  $len ||= $SHOWLENGTH;
  for ($n = 0; $showall || $n < $len; $n++) {
    if ($s->is_empty) {
      print "\n";
      return;
    }
    print $s->head, " ";
    $s = $s->tail;
  }
  print "\n";
}

## $f, $f+1, $f+2, ... $t-1, $t.
sub upto {
  my $f = shift;
  my $t = shift;
  return Stream->empty if $f > $t;
  Stream->new($f, sub { &upto($f+1, $t) });
}

## 1, 2, 3, 4, 5, ...
sub iota {
  &tabulate(sub {$_[0]}, 1);  # Tabulate identity function
}

## Return a stream of all the elements of s for which predicate p is true.
sub filter {
  my $s = shift;

  # Second argument is a predicate function that returns true
  # only when passed an interesting element of $s.
  my $predicate = shift;

  # Look for next interesting element
  until ( $s->is_empty ||  &$predicate($s->head)) {
    $s = $s->tail;
  }

  # If we ran out of stream, return the empty stream.
  return $s->empty if $s->is_empty;

  # Construct new stream with the interesting element at its head
  # and the rest of the stream, appropriately filtered,
  # at its tail.
  Stream->new($s->head,
              sub { $s->tail->filter($predicate) }
             );
}



## Given a stream s1, s2, s3, ... return f(s1), f(s2), f(s3), ...
sub transform {
  my $s = shift;
  return $s->empty if $s->is_empty;

  my $map_function = shift;
  Stream->new(&$map_function($s->head),
              sub { $s->tail->transform($map_function) }
             );
}

# Emit elements of a stream s, chopping it off at the first element
# for which `$predicate' is true
sub chop_when {
  my $s = shift;
  my $predicate = shift;
  return $s->empty if $s->is_empty || &$predicate($s->head);
  Stream->new($s->head, sub {$s->tail->chop_when($predicate)});
}

# Return first element $h of $s, and sieve out
# subsequent elements, discarding those that are divisible by $h.
sub prime_filter {
  my $s = shift;
  my $h = $s->head;
  Stream->new($h, sub { $s->tail
                          ->filter(sub { $_[0] % $h })
                          ->prime_filter()
                      });
}

# Multiply every element of a stream $s by a constant $n.
sub scale {
  my $s = shift;
  my $n = shift;
  $s->transform(sub { $_[0] * $n });
}

# Merge two streams of numbers in ascending order, discarding duplicates
sub merge {
  my $s1 = shift;
  my $s2 = shift;
  return $s2 if $s1->is_empty;
  return $s1 if $s2->is_empty;
  my $h1 = $s1->head;
  my $h2 = $s2->head;
  if ($h1 > $h2) {
    Stream->new($h2, sub { &merge($s1, $s2->tail) });
  } elsif ($h1 < $h2) {
    Stream->new($h1, sub { &merge($s1->tail, $s2) });
  } else {			# heads are equal
    Stream->new($h1, sub { &merge($s1->tail, $s2->tail) });
  }
}

# Given two streams s1, s2, s3, ... and t1, t2, t3, ...
# construct s1, t1, s2, t2, s3, t3, ...
sub mingle {
  my $s = shift;
  my $t = shift;

  return $t if $s->is_empty;
  return $s if $t->is_empty;
  Stream->new($s->head, sub {&mingle($t, $s->tail)});
}



# This is not a very good way to do it.
sub hamming_slow {
  my $n = shift;
  Stream->new($n,
      sub { &merge(&hamming_slow(2*$n),
		   &merge(&hamming_slow(3*$n),
			  &hamming_slow(5*$n),
			  ))
	      });
}

# This is the good one.
#
# The article says it takes a few minutes to compute 3,000 numbers on
# the dinky machine.  That turns out to be not because the dinky
# machine was slow, but because it had so little memory.  With an
# extra 24 MB of memory, computing 3,000 numbers takes just under 20
# seconds of CPU time.
#
sub hamming {
  my $href = \1;		# Dummy reference
  my $hamming =
      Stream->new(1,
	  sub { &merge($$href->scale(2),
		       &merge($$href->scale(3),
			      $$href->scale(5)
			      ))
		  }
          );
  $href = \$hamming;      # Reference is no longer a dummy
  $hamming;
}

# Rujith S. de Silva points out that the `dummy reference' hack
# is unneccesary.  This version is easier to understand and probably
# faster than the `hamming' above:
#
sub hamming_r {
  my $hamming;
  $hamming =
      Stream->new(1,
	  sub { &merge($hamming_r->scale(2),
		&merge($hamming_r->scale(3),
		       $hamming_r->scale(5)
		       ))
		  }
      );
}

sub squares_from {
  my $n = shift;
  print STDERR "SQUARES_FROM($n)\n" if $DEBUG;
  Stream->new($n*$n,
	      sub { &squares_from($n+1) });
}

# Hailstone number iterator
sub next_hail {
  my $n = shift;
  ($n % 2 == 0) ? $n/2 : 3*$n + 1;
}

# Return the Collatz 3n+1 sequence starting from n.
sub hailstones {
  my $n = shift;
  &iterate(\&next_hail, $n);
}


# Example random number generator from ANSI C standard
sub next_rand { int(($_[0] * 1103515245 + 12345) / 65536) % 32768 }

# Stream of random numbers, seeded by $seed.
sub rand {
  my $seed = shift;
  &iterate(\&next_rand, &next_rand($seed));
}

# Auxiliary function for &iterate_chop
sub iter_pairs {
  my $s = shift;
  my $ss = shift;
  return $s->empty if $s->is_empty;
  Stream->new([$s->head, $ss->head],
	      sub {&iter_pairs($s->tail, $ss->tail->tail)}
	);
}

# Given a stream of numbers generated by `iterate',
# chop it off before it repeats.
# Not guaranteed to do anything useful if applied to a stream that was
# not produced by `iterate'
sub iterate_chop {
   my $s = shift;
   return $s->empty if $s->is_empty;
   &iter_pairs($s, $s->tail)
       ->chop_when(sub {$_[0][0] == $_[0][1]})
	   ->transform(sub {$_[0][0]});
}



# Given a regular list of values, produce a finite stream
sub list2stream {
  return Stream->empty unless @_;
  my @list = @_;
  my $h = shift @list;
#  print STDERR "list2stream @_\n";
  return Stream->new($h, sub{&list2stream(@list)});
}

## Turn a stream into a regular Perl array
## Caution--only works on finite streams
sub stream2list {
  my $s = shift;
  my @r;
  while (! $s->is_empty) {
    push @r, $s->head;
    $s = $s->tail;
  }
  @r;
}


## Compute length of given stream
sub length {
  my $s = shift;
  my $n = 0;
  while (! $s->is_empty) {
    $s = $s->tail;
    $n++;
  }
  $n;
}

1;

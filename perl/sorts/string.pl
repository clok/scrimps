use strict;
use warnings;

use Data::Dumper;

$| = 1;

# QuickSort
sub perl_sort {
  my $array = shift;
  return sort @$array;
}

sub dict_sort {
  my $array = shift;
  return sort {
    my $da = lc $a;
    my $db = lc $b;
    $da =~ s/[\W_]//g;
    $db =~ s/[\W_]//g;
    $da cmp $db;
  } @$array;
}

sub dict_opt_sort {
  my $array = shift;
  return map { $_->[0] }
    sort { $a->[1] cmp $b->[1] }
      map {
        my $d = lc;
        $d =~ s/[\W_]//g;
        [ $_, $d ];
      }
    @$array;
}

{
  use Benchmark qw( timethese cmpthese );

  srand;

  my @array;
  my @sorted;

  for (1..1000) {
    push @array, sprintf("%08X", rand(0xffffffff));
  }

  # mutate array
  for (@array) {
    if (rand() < 0.5) {
      $_ = lcfirst;
    }
    if (rand() < 0.25) {
      substr($_, rand(length), 0) = '_';
    }
    if (rand() < 0.333) {
      $_ .= $_;
    }
    if (rand() < 0.333) {
      $_ .= reverse $_;
    }
    if (rand() > 1/length) {
      substr($_, rand(length), rand(length)) = '';
    }
  }

  my $results = timethese(1000, {
    'perl_sort'     => sub { perl_sort(\@array) },
    'dict_sort'     => sub { dict_sort(\@array) },
    'dict_opt_sort' => sub { dict_opt_sort(\@array) }
  });

  cmpthese( $results ) ;
}

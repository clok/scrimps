use strict;
use warnings;

use Data::Dumper;

$| = 1;

# ($link, $node) = basic_tree_find(\$tree, $target[, $cmp])
sub basic_tree_find {
  my ($tree_link, $target, $cmp) = @_;
  my $node;

  # $tree_link is the next link to be followed
  # It will be undef if we reach the bottom of the tree
  while ($node = $$tree_link) {
    local $^W = 0; # There will be undef warnings

    # 0 || 1 || -1
    my $relation = ( defined $cmp ? $cmp->($target, $node->{val}) : $target <=> $node->{val} );

    # Found
    return ($tree_link, $node) if $relation == 0;

    # Not Found
    $tree_link = $relation > 0 ? \$node->{left} : \$node->{right};
  }

  # Reached the bottom
  return ($tree_link, undef);
}

# $node = basic_tree_add(\$tree, $target[, $cmp])
sub basic_tree_add {
  my ($tree_link, $target, $cmp) = @_;
  my $found;

  ($tree_link, $found) = basic_tree_find($tree_link, $target, $cmp);

  unless ($found) {
    $found = {
      left  => undef,
      right => undef,
      val   => $target
    };
    $$tree_link = $found;
  }

  return $found;
}

# $val = basic_tree_del(\$tree, $target[, $cmp])
sub basic_tree_del {
  my ($tree_link, $target, $cmp) = @_;
  my $found;

  ($tree_link, $found) = basic_tree_find($tree_link, $target, $cmp);

  return undef unless $found;

  # tree_link has to be made to point to any children of $found
  #  if there are no children, make it null
  #  if there is only one child, it can just take the place of $found
  #  if there are more than one children, must merge to fit in the single reference.
  if (!defined $found->{left}) {
    $$tree_link = $found->{right};
  } elsif (!defined $found->{right}) {
    $$tree_link = $found->{left};
  } else {
    merge_tree_link($tree_link, $found);
  }

  return $found->{val};
}

# Make $tree_link point to both $found->{left} and $found->{right}
#
# Simple:
# 1. Attach $found->{left} to the leftmost child of $found->{right}
# 2. Then attach $found->{right} to $$tree_link
sub merge_tree_link {
  my ($tree_link, $found) = @_;
  my $left_to_right = $found->{right};
  my $next_left;

  $left_to_right = $next_left
    while $next_left = $left_to_right->{left};

  $left_to_right->{left} = $found->{left};

  $$tree_link = $found->{right};
}

{
  my $tree;

  foreach (1..10) {
    #my $i = int(rand(10)) + $_;
    basic_tree_add(\$tree, $_);
  }

  print Dumper($tree);
}

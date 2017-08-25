use strict;
use warnings;

use Data::Dumper;

$| = 1;

# traverse($tree, $func)
# Call func on each element in order
sub traverse {
  my $tree = shift or return; # skip undef pointers
  my $func = shift;

  traverse($tree->{left}, $func);
  &$func($tree);
  traverse($tree->{right}, $func);
}

# $node = bal_tree_find($tree, $val[, $cmp])
sub bal_tree_find {
  my ($tree, $val, $cmp) = @_;
  my $result;

  while ($tree) {
    my $relation = defined $cmp
      ? $cmp->($tree->{val}, $val)
      : $tree->{val} <=> $val;

    # Found
    return if $relation == 0;

    # Select correct subtree
    $tree = $relation < 0 ? $tree->{left} : $tree->{right};
  }

  # Not found
  return undef
}

# ($tree, $node) = bal_tree_add($tree, $val[, $cmp])
sub bal_tree_add {
  my ($tree, $val, $cmp) = @_;
  my $result;

  # Return a new tree (single leaf) if leaf is undefined
  unless ($tree) {
    $result = {
      left   => undef,
      right  => undef,
      val    => $val,
      height => 1
    };
    return($result, $result)
  }

  my $relation = defined $cmp
    ? $cmp->($tree->{val}, $val)
    : $tree->{val} <=> $val;

  # Found the node
  return($tree, $tree) if $relation == 0;

  # add to correct subtree
  if ($relation < 0) {
    ($tree->{left}, $result) = bal_tree_add($tree->{left}, $val, $cmp);
  } else {
    ($tree->{right}, $result) = bal_tree_add($tree->{right}, $val, $cmp);
  }

  # Balance the tree at this level
  return(balance_tree($tree), $result);
}

# ($tree, $node) = bal_tree_del($tree, $val[, $cmp])
sub bal_tree_del {
  # An empty subtree does not contain the target
  my $tree = shift or return(undef,undef);

  my ($val, $cmp) = @_;
  my $node;

  my $relation = defined $cmp
    ? $cmp->($tree->{val}, $val)
    : $tree->{val} <=> $val;

  if ($relation != 0) {
    # Not in this tree, go down a level
    if ($relation < 0) {
      ($tree->{left}, $node) = bal_tree_del($tree->{left}, $val, $cmp);
    } else {
      ($tree->{right}, $node) = bal_tree_del($tree->{right}, $val, $cmp);
    }

    # No balancing required if node was not found
    return($tree,undef) if $node;
  } else {
    # Must delete this node. Will need to return it.
    $node = $tree;

    # Then splice the rest of the tree back together first
    $tree = bal_tree_join($tree->{left}, $tree->{right});

    # Force node to forget children
    $node->{left} = $node->{right} = undef;
  }

  # Final check that the level is balanced
  return(balance_tree($tree), $node);
}

# $tree = bal_tree_join($left, $right);
sub bal_tree_join {
  my ($l, $r) = @_;

  # simple case: one or both are undef
  return $l unless defined $r;
  return $r unless defined $l;

  # time to merge
  my $top;

  if ($l->{height} > $r->{height}) {
    $top = $l;
    $top->{right} = bal_tree_join($top->{right}, $r);
  } else {
    $top = $r;
    $top->{left} = bal_tree_join($l, $top->{left});
  }
  return balance_tree($top);
}

# $tree = balance_tree($tree)
# Modified AVL - Track Height
sub balance_tree {
  # An empty tree is already balanced
  my $tree = shift or return undef;

  # An empty link is height 0
  my $lh = defined $tree->{left} && $tree->{left}{height};
  my $rh = defined $tree->{right} && $tree->{right}{height};

  # Rebalance if needed
  if ($lh > 1+$rh) {
    return swing_right($tree);
  } elsif ($lh+1 < $rh) {
    return swing_left($tree);
  } else {
    # The tree is either perfectly balanced or off by one.
    # Just fix the height
    set_height($tree);
    return $tree;
  }
}

# set_height($tree)
sub set_height {
  my $tree = shift;
  my $p;

  # get heights, undef = 0
  my $lh;
  my $rh;
  $lh = defined ($p = $tree->{left})  && ($lh = $p->{height});
  $rh = defined ($p = $tree->{right}) && ($rh = $p->{height});
  $tree->{height} = $lh < $rh ? $rh+1 : $lh+1;
}

sub swing_left {
  my $tree = shift;
  my $r    = $tree->{right}; # must exist
  my $rl   = $r->{left};     # might exist
  my $rr   = $r->{right};    # might exist
  my $l    = $tree->{left};  # might exist

  # get heights, undef = 0
  my $lh = $l && $l->{height} || 0;
  my $rlh = $rl && $rl->{height} || 0;
  my $rrh = $rr && $rr->{height} || 0;

  if ($rlh > $rrh) {
    $tree->{right} = move_right($r);
  }

  return move_left($tree);
}

sub swing_right {
  my $tree = shift;
  my $l    = $tree->{left};  # must exist
  my $lr   = $l->{right};    # might exist
  my $ll   = $l->{left};     # might exist
  my $r    = $tree->{right}; # might exist

  # get heights, undef = 0
  my $rh = $r && $r->{height} || 0;
  my $lrh = $lr && $lr->{height} || 0;
  my $llh = $ll && $ll->{height} || 0;

  if ($lrh > $llh) {
    $tree->{left} = move_left($l);
  }

  return move_right($tree);
}

# $tree = move_left($tree)
sub move_left {
  my $tree = shift;
  my $r = $tree->{right};
  my $rl = $r->{left};

  $tree->{right} = $rl;
  $r->{left} = $tree;
  set_height($tree);
  set_height($r);
  return $r;
}

# $tree = move_right($tree)
sub move_right {
  my $tree = shift;
  my $l = $tree->{left};
  my $lr = $l->{right};

  $tree->{left} = $lr;
  $l->{right} = $tree;
  set_height($tree);
  set_height($l);
  return $l;
}

{
  my $tree = undef;
  my $node;

  foreach(1..8) {
    ($tree, $node) = bal_tree_add($tree, $_ * $_);
  }

  ($tree, $node) = bal_tree_del($tree, 7*7);

  # my $tree = undef;
  # my $node;
  #
  # foreach (1..10) {
  #   ($tree, $node) = bal_tree_add($tree, $_ * $_);
  # }

  print Dumper($tree);
}

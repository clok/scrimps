use strict;
use warnings;

use Data::Dumper;

$| = 1;

{
  # double - Doubley linked list

  package double;

  sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $self = { value=>shift };
    bless $self, $class;
    return $self->_link_to($self);
  }

  sub content {
    return shift;
  }

  sub destroy {
    my $node = shift;
    while ($node) {
      my $next = $node->next;
      $node->prev(undef);
      $node->next(undef);
      $node = $next;
    }
  }

  sub next {
    my $node = shift;
    return @_ ? ($node->{next} = shift) : $node->{next};
  }

  sub prev {
    my $node = shift;
    return @_ ? ($node->{prev} = shift) : $node->{prev};
  }

  # insert after node
  sub append {
    my ($node, $add) = @_;
    if ($add = $add->content) {
      $add->prev->_link_to($node->next);
      $node->_link_to($add);
    }
  }

  # insert before node
  sub prepend {
    my ($node, $add) = @_;
    if ($add = $add->content) {
      $node->prev->_link_to($add->next);
      $add->_link_to($node);
    }
  }

  sub remove {
    my $first = shift;
    my $last = shift || $first;

    $first->prev->_link_to($last->next);

    $last->_link_to($first);
    return $first;
  }

  # internal mechanism with no care of direction link goes
  sub _link_to {
    my ($node, $next) = @_;

    $node->next($next);
    return $next->prev($node);
  }
}

{
  # double_head - Head element of DLL

  package double_head;

  sub new {
    my $class = shift;
    my $info = shift;
    my $dummy = double::->new;

    bless [$dummy, $info], $class;
  }

  sub DESTROY {
    my $self = shift;
    my $dummy = $self->[0];

    $dummy->destroy;
  }

  sub append {
    my $self = shift;
    $self->[0]->prepend(shift);
    return $self;
  }

  sub prepend {
    my $self = shift;
    $self->[0]->append(shift);
    return $self;
  }

  sub first {
    my $self = shift;
    my $dummy = $self->[0];
    my $first = $dummy->next;

    return $first == $dummy ? undef : $first;
  }

  sub last {
    my $self = shift;
    my $dummy = $self->[0];
    my $last = $dummy->prev;

    return $last == $dummy ? undef : $last;
  }

  sub content {
    my $self = shift;
    my $dummy = $self->[0];
    my $first = $dummy->next;
    return undef if $first eq $dummy;
    $dummy->remove;
    return $first;
  }

  sub ldump {
    my $self = shift;
    my $start = $self->[0];
    my $cur = $start->next;
    print "list(".$self->[1].") [";
    my $sep = "";

    while ($cur ne $start) {
      print $sep, $cur->{value};
      $sep = ",";
      $cur = $cur->next
    }
    print "]\n";
  }
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

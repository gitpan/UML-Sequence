=head1 NAME

UML::Sequence - This package makes UML sequence diagrams, often by running the code.

=head1 SYNOPSIS

  use UML::Sequence;

  my $tree = UML::Sequence->new(\@methods, \@outline, \&parse_method);
  print $tree->build_xml_sequence('Title');

=head1 DESCRIPTION

To use this package, or see how to use it, see L<genericseq.pl> and
L<seq2svg.pl>.

This class helps produce UML sequence diagrams.  build_xml_sequence
returns a string (suitable for printing to a file) which the seq2svg.pl
script converts into svg.

To control the appearance of the sequence diagram, pass to the constructor:

1 a reference to an array containing the signatures you want to hear about
  or a reference to a hash whose keys are the signatures you want
2 a reference to an array containing the lines in the outline of calls
3 a reference to a sub which takes signatures and returns class and method names

To build the array references and supply the code reference consult
UML::Sequence::SimpleSeq, UML::Sequence::JavaSeq, or UML::Sequence::PerlSeq.
To see one way to call these look in the supplied genericseq script.

=head2 EXPORT

None, this module is object oriented.

=cut

package UML::Sequence;

require 5.005_62;
use strict;
use warnings;

our $VERSION = '0.05';

use UML::Sequence::Activation;

sub new {
    my $class              = shift; # standard
    my $methods_to_include = shift; # array or hash of methods you want to see
    my $input              = shift; # the outline of calls
    my $parse_signature    = shift; # code ref which returns class and method

    my $methods_hash;
    if (ref($methods_to_include) =~ /ARRAY/) {
        $methods_hash = _build_methods_hash($methods_to_include);
    }
    else {
        $methods_hash = $methods_to_include;
    }

    my $stack = [];
    my $root = {
        LEVEL   => -1,
        DATA    => [],
        NAME    => scalar &$parse_signature(shift @$input),
        DISCARD => 0,
    };

    my $self = {};
    $self->{TREE}     = $root;
    $self->{STACK}    = $stack;
    $self->{INCLUDE}  = $methods_hash;
    $self->{SIGPARSE} = $parse_signature;
    bless $self, $class;

    push @$stack, $root;

# 2.
    foreach (@$input) {
        my $input_line = $_;
        my $depth;

        if ($input_line =~ s/^(\s+)//) { $depth = length $1; }
        else                           { $depth = 0;         }

        $self->_update_stack($input_line, $depth);
    }
    return $self;
}

sub _grab_outline_text {
# 1a.
    _run_dprof(@_);

# 1b.
    my $input = _read_dprofpp();
# The next line uses the sample data in __DATA__ see the comment there
#    my $input = _read_sample();
    return $input;
}

sub _build_methods_hash {
    my $methods_list = shift;
    my %methods_hash;

    foreach my $method (@$methods_list) {
        $methods_hash{$method}++;
    }
    return \%methods_hash;
}

#sub _read_sample {
#    my @retval = map { chomp $_; $_; } <DATA>;
#    return \@retval;
#}

sub _update_stack {
    my $self     = shift;
    my $method   = shift;
    my $level    = shift;
    my $new_node = {
         LEVEL   => $level,
         DATA    => [],
         NAME    => $method,
#        DISCARD => 0,
    };

    while ($level <= $self->{STACK}[-1]{LEVEL}) {
        pop @{$self->{STACK}};
    }

    $new_node->{DISCARD} = $self->{STACK}[-1]{DISCARD};
    unless (defined $self->{INCLUDE}{$method}) {
        $new_node->{DISCARD} = 1;
    }

    push @{$self->{STACK}[-1]{DATA}}, $new_node;
    push @{$self->{STACK}}, $new_node;
}

sub print_tree {
    my $self   = shift;

    return _print_tree($self->{TREE}, "");
}

sub _print_tree {
    my $root   = shift;
    my $indent = shift;
    my $retval;

    return unless defined $root;  # recursion base
    return if ($root->{DISCARD});

    $retval = "$indent$root->{NAME}\n";

    foreach my $child (@{$root->{DATA}}) {
        my $child_output = _print_tree($child, "$indent  ");
        $retval         .= $child_output if $child_output;
    }
    return $retval;
}

sub build_xml_sequence {
    my $self  = shift;
    my $title = shift;

    $self->{ARROW_NUM}  = 0;
    $self->{ARROW_LIST} = "<arrow_list>\n";
    $self->_build_xml_sequence($self->{TREE});
    $self->{ARROW_LIST} .= "</arrow_list>\n";

    $self->_build_class_list();
    if ($title) {
        return "<?xml version='1.0' ?>\n<sequence title='$title'>\n"
             . "$self->{CLASS_LIST}\n"
             . "$self->{ARROW_LIST}</sequence>\n";
    }
    else {
        return "<?xml version='1.0' ?>\n<sequence>\n$self->{CLASS_LIST}\n"
             . "$self->{ARROW_LIST}</sequence>\n";
    }
}

sub _build_xml_sequence {
    my $self = shift;
    my $root = shift;  # you must pass this in, $self->{TREE} never changes

    # recursion bases
    return unless defined $root;
    return if $root->{DISCARD};
    my $root_call = $root->{NAME};
    return unless defined $root_call;

    my $class = $self->{SIGPARSE}($root_call);

    # put into to class list, if it isn't already there
    if (not defined $self->{ACTIVATIONS}{$class}) {
        push @{$self->{CLASSES}}, $class;
    }

    # create activation and add it to the list for this class
    my $activation = UML::Sequence::Activation->new();
    $activation->starts($self->{ARROW_NUM});
    my $offset = UML::Sequence::Activation
        ->find_offset($self->{ACTIVATIONS}{$class});
    $activation->offset($offset);

    push @{$self->{ACTIVATIONS}{$class}}, $activation;

    # visit children
    foreach my $child (@{$root->{DATA}}) {
        next if $child->{DISCARD};

        my ($child_class, $method) = $self->{SIGPARSE}($child->{NAME});
        my $child_offset =
            UML::Sequence::Activation
                ->find_offset($self->{ACTIVATIONS}{$child_class});

        $self->{ARROW_NUM}++;
        $self->{ARROW_LIST} .=
          "  <arrow from='$class' to='$child_class' type='call' " .
          "label='$method'\n"                                     .
          "         from-offset='$offset' to-offset='$child_offset' />\n";
        $self->_build_xml_sequence($child);
    }

    $activation->ends($self->{ARROW_NUM});
}

sub _build_class_list {
    my $self = shift;
    $self->{CLASS_LIST} = "<class_list>\n";

    foreach my $class (@{$self->{CLASSES}}) {
        my ($starts, $ends) =
            UML::Sequence::Activation
                ->find_bounds($self->{ACTIVATIONS}{$class});
        $self->{CLASS_LIST} .=
            "  <class name='$class' born='$starts' extends-to='$ends'>\n" .
            "    <activation_list>\n";

        foreach my $activation (@{$self->{ACTIVATIONS}{$class}}) {
            my $act_start = $activation->starts();
            my $act_end    = $activation->ends();
            my $act_offset = $activation->offset();
            $self->{CLASS_LIST} .=
                "      <activation born='$act_start' extends-to='$act_end' " .
                "offset='$act_offset' />\n";
        }
        $self->{CLASS_LIST} .= "    </activation_list>\n  </class>\n";
    }
    $self->{CLASS_LIST} .= "</class_list>\n";
}

1;
# EDIT HISTORY
#
# 0.01 Jan 2003  Initial release.
# 0.02 Feb 2003  See Changes file (this release didn't affect this file)
# 0.03 Mar 2003  See Changes
# 0.04 Mar 2003  See Changes

=head1 AUTHOR
 
Phil Crow, <philcrow2000@yahoo.com>
  
=head1 SEE ALSO

L<genericseq.pl>
L<seq2svg.pl>

=head1 COPYRIGHT
   
Copyright 2003, Philip Crow, all rights reserved.  You may modify and/or
redistribute this code in the same manner as Perl itself.

=cut

# This data is a small subset of a typical dprofpp -T output.
# It's used by _read_sample so you can debug with a small input set.
# Use _read_sample in place of _read_dprofpp to switch to this set.
__DATA__
DiePair::new
   Die::new
   Die::new
DiePair::roll
   Die::roll
   Die::roll
DiePair::total
DiePair::doubles
DiePair::to_string


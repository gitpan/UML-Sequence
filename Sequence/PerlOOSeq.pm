package UML::Sequence::PerlOOSeq;
use     strict;
use     warnings;

=head1 NAME

UML::Sequence::PerlOOSeq - helper for genericseq.pl showing object instances

=head1 SYNOPSIS
 
     genericseq.pl UML::Sequence::PerlOOSeq methods_file perl_program [args...] > sequence.xml
     seq2svg.pl sequence.xml > sequence.svg
          
OR
           
     genericseq.pl UML::Sequence::PerlOOSeq methods_file program [args...] | seq2svg.pl > sequence.svg

=cut

use strict;
use warnings;

our $VERSION = "0.01";

my $methods_file;

=head1 grab_outline_text

Call this method first.  Call it through the class
(UML::Sequence::PerlOOSeq->grab_outline_text)
passing it the methods_file, the program to run, and any args for that program.
Returns an outline (suitable for printing or passing on to UML::Sequence).

=cut
sub grab_outline_text {
    shift;  # discard class name
    $methods_file = shift;
    _profile(@_);
    return _read_tmon();
}

sub _profile {
    `perl -d:OOCallSeq @_`;
}

sub _read_tmon {
    my @retval;
    open TMON, "tmon.out" or die "Couldn't run dprofpp\n";
    while (<TMON>) {
        chomp;
        push @retval, $_;
    }
    return \@retval;
}

=head1 grab_methods

Call this only after you have called grab_outline.  Call it through the class:
PerlSeq->grab_methods.  Arguments are ignored.
Returns a reference to an array listing the methods of interest.

=cut

sub grab_methods {
    shift;  # discard class

    open METHODS, "$methods_file" or die "Couldn't open $methods_file\n";
    chomp(my @methods = <METHODS>);
    close METHODS;

    return \@methods;
}

=head1 parse_signature

Pass a reference to this method to the SeqOutline constructor.  It must
accept a method signature and return the class name (in scalar context) or
the class and method names in that order (in list context).

=cut

sub parse_signature {
    my $signature = shift;
    my $class     = $signature;
    $class        =~ s/::([^:]+)$//;
    my $method    = $1;

    return wantarray ? ($class, $method) : $class;
}

# EDIT HISTORY:
# 0.01  Feb 28, 2003 Initial Release (with UML-Sequence-0.02)
#                    This code is only a slight revision of PerlSeq.  Here
#                    I use Devel::OOCallSeq instead of Devel::CallSeq.
#                    So, this script has one life line per instance instead
#                    of one life line per class.

1;

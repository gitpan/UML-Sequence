#!/usr/bin/perl
use strict;
use warnings;

=head1 NAME

seq2svg - a script to convert xml sequence diagrams to svg

=head1 USAGE

    seq2svg [-o output_file_name] [input_file_name]

=cut

use UML::Sequence::Svg;

seq2svg(@ARGV);

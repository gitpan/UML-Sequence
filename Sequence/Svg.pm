=head1 NAME

UML::Sequence::Svg - converts xml sequence files to svg

=head1 SYNOPSIS

    use UML::Sequence::Svg;

    seq2svg @ARGV;

=head1 DESCRIPTION

This module supports the seq2svg.pl script like Pod::Html supports pod2html.
The array passed to seq2svg.pl should have the following form:

    [-o output_file_name] [input_file_name]

By default input is from standard in and output is to standard out.

=cut

package UML::Sequence::Svg;

use Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw(seq2svg);

use strict;

use XML::DOM;
use Getopt::Std;

# Constant declarations.
my $CLASS_TEXT_Y      =  40;
my $CLASS_BOX_Y       =  25;
my $CLASS_BOX_HEIGHT  =  20;
my $CLASS_BOX_WIDTH   = 125;
my $CLASS_SPACING     =   3;

my $LEFT_EDGE         =  30;

my $ACTIVATION_WIDTH  =  15;
my $ACTIVATION_OFFSET =  10;

my $FIRST_ARROW       =  55;
my $ARROW_SPACING     =  40;

# Global variable:
my $output_file = "-";

sub seq2svg {
    local (@ARGV) = @_;
    parse_command_line();

    my $input_file = shift @ARGV;

    if (defined $input_file) {
        open INPUT, "$input_file"
            or die "Couldn't open $input_file for input: $!\n";
    }
    else {
        *INPUT = *STDIN;
    }

    my $parser       = XML::DOM::Parser->new();
    my $doc          = $parser->parse(*INPUT);

    my $sequence     = $doc->getDocumentElement();
    my $title        = $sequence->getAttribute("title");

    my $classes      = $doc->getElementsByTagName("class");
    my $class_output = draw_classes($classes);
    my $class_hash   = build_class_name_hash($classes);
    my $arrow_output = draw_arrows($doc, $class_hash);
    my $class_count  = scalar (keys %$class_hash);
    my $arrow_count  = count_arrows($doc);
    my $width        = $class_count * ($CLASS_BOX_WIDTH + $CLASS_SPACING) + 40;
    my $height       = 2.5 * $CLASS_TEXT_Y + $arrow_count * ($ARROW_SPACING);

    open SVGOUT, ">$output_file";

    print SVGOUT <<EOJ;
<?xml version="1.0"?>
  <svg xmlns="http://www.w3.org/2000/svg" height="$height" width="$width">
    <defs>
      <style type="text/css">
              rect, line, path { stroke-width: 2; stroke: black }
              text { font-weight: bold }
      <marker orient="auto" refY="2.5" refX="4" markerHeight="5" 
              markerWidth="4" id="mArrow">
        <path style="fill: black; stroke: none" d="M 0 0 4 2 0 5"/>
      </marker>
      </style>
    </defs>
EOJ

    if ($title) {
        print SVGOUT <<EOJ;
    <text x="5" y="15">
        $title
    </text>
EOJ
    }

    print SVGOUT <<EOJ;
$class_output$arrow_output</svg>
EOJ

}

sub draw_classes {
  my $classes = shift;
  my $retval;

  my $x        = $LEFT_EDGE;
  my $box_left = $LEFT_EDGE - 8;
  my $y        = $CLASS_TEXT_Y;
  my $max_extent;

  for (my $i = 0; $i < $classes->getLength(); $i++) {
    my $class      = $classes->item($i);
    my $life_x     = int($x + $CLASS_BOX_WIDTH / 2);
    my $class_name = $class  ->getAttribute("name");
    my $born       = $class  ->getAttribute("born")
                     * $ARROW_SPACING + $FIRST_ARROW;
    my $extends_to = ($class ->getAttribute("extends-to") + 1)
                     * $ARROW_SPACING + $FIRST_ARROW;
    if (not defined $max_extent) { $max_extent = $extends_to; }
    $retval .= "<text y='$CLASS_TEXT_Y' x='$x'>$class_name</text>\n";
    $retval .= "  <rect style='fill: none' height='$CLASS_BOX_HEIGHT' "
            . "width='$CLASS_BOX_WIDTH' y='$CLASS_BOX_Y' x='$box_left' />\n";
    $retval .= "  <line style='stroke-dasharray: 4,4; ' fill='none' "
            .  "stroke='black' x1='$life_x' y1='$born' x2='$life_x' "
            .  "y2='$max_extent' />\n";

    my $activation_x = int($box_left + $CLASS_BOX_WIDTH / 2);
    my @activations  = $class->getElementsByTagName("activation");
    foreach my $activation (@activations) {
      my $born       = $activation->getAttribute("born");
      my $extends_to = $activation->getAttribute("extends-to");
      my $offset     = $activation->getAttribute("offset");
      my $top        = $FIRST_ARROW  + $born       * $ARROW_SPACING;
      my $height     = ($extends_to  - $born + .5) * $ARROW_SPACING;
      my $left       = $activation_x + $offset     * $ACTIVATION_OFFSET;
      $retval .= "    <rect style='fill: white' height='$height' "
          . "width='$ACTIVATION_WIDTH' y='$top' x='$left'/>\n";
    }

    $x        += $CLASS_BOX_WIDTH + $CLASS_SPACING;
    $box_left += $CLASS_BOX_WIDTH + $CLASS_SPACING;
    $retval .= "\n";
  }
  return $retval;
}

sub count_arrows {
  my $doc    = shift;
  my $arrows = $doc->getElementsByTagName("arrow");
  return $arrows->getLength();
}

sub draw_arrows {
  my $doc        = shift;
  my $class_hash = shift;
  my $retval;

  my $arrows     = $doc->getElementsByTagName("arrow");

  for (my $i = 0; $i < $arrows->getLength(); $i++) {
    my $arrow = $arrows->item($i);
    my $from         = $arrow->getAttribute("from"       );
    my $to           = $arrow->getAttribute("to"         );
    my $type         = $arrow->getAttribute("type"       );
    my $label        = $arrow->getAttribute("label"      );
    my $from_offset  = $arrow->getAttribute("from-offset");
    my $to_offset    = $arrow->getAttribute("to-offset"  );
    my $y            = $FIRST_ARROW + ($i + 1) * $ARROW_SPACING;
    my $from_number  = $class_hash->{$from};
    my $to_number    = $class_hash->{$to};
    $label =~ s/</&lt;/g;
    $label =~ s/>/&gt;/g;
    if    ($from_number < $to_number) {  # arrow from left to right
      my $x1 = $from_number * ($CLASS_BOX_WIDTH + $CLASS_SPACING) + $LEFT_EDGE
               + ($CLASS_BOX_WIDTH + $ACTIVATION_WIDTH)/2
               + $from_offset * $ACTIVATION_OFFSET;
      my $x2 = $to_number   * ($CLASS_BOX_WIDTH + $CLASS_SPACING) + $LEFT_EDGE
               + ($CLASS_BOX_WIDTH - $ACTIVATION_WIDTH)/2;
      my $xlab = $x1 + $CLASS_SPACING;
      my $ylab = $y  - 6;
      $retval .= "<line x1='$x1' y1='$y' x2='$x2' y2='$y' "
              .  "style='marker-end: url(#mArrow);' />\n";
      $retval .= "<text x='$xlab' y='$ylab'>$label</text>\n" if defined $label;
    }
    elsif ($from_number > $to_number) {  # arrow from right to left
      my $x1 = $from_number * ($CLASS_BOX_WIDTH + $CLASS_SPACING) + $LEFT_EDGE
               + ($CLASS_BOX_WIDTH - $ACTIVATION_WIDTH)/2;
      my $x2 = $to_number   * ($CLASS_BOX_WIDTH + $CLASS_SPACING) + $LEFT_EDGE
               + ($CLASS_BOX_WIDTH + $ACTIVATION_WIDTH)/2
               + $to_offset * $ACTIVATION_OFFSET;
      $retval .= "<line x1='$x1' y1='$y' x2='$x2' y2='$y' "
              .  "style='marker-end: url(#mArrow);' />\n";
      my $xlab = $x2 + $CLASS_SPACING;
      my $ylab = $y  - 6;
      $retval .= "<text x='$xlab' y='$ylab'>$label</text>\n" if defined $label;
    }
    else {               # arrow from and to same class
      my $x1 = $from_number * ($CLASS_BOX_WIDTH + $CLASS_SPACING) + $LEFT_EDGE
               + ($CLASS_BOX_WIDTH + $ACTIVATION_WIDTH)/2
               + $from_offset * $ACTIVATION_OFFSET;
      my $x2 = $to_number   * ($CLASS_BOX_WIDTH + $CLASS_SPACING) + $LEFT_EDGE
               + ($CLASS_BOX_WIDTH + $ACTIVATION_WIDTH)/2
               + $to_offset * $ACTIVATION_OFFSET;
      $y -= 10;
      my $y2 = $y + 20;
      my $x1padded = $x1 + $ACTIVATION_OFFSET + 15;
      $retval .= "<line x1='$x1' y1='$y' x2='$x1padded' y2='$y' />\n"
              .  "<line x1='$x1padded' y1='$y' x2='$x1padded' y2='$y2' />\n"
              .  "<line x1='$x1padded' y1='$y2' x2='$x2' y2='$y2' "
              .  "style='marker-end: url(#mArrow);' />\n";
      my $xlab = $x1padded + $CLASS_SPACING;
      my $ylab = ($y + $y2) / 2;
      $retval .= "<text x='$xlab' y='$ylab'>$label</text>\n" if defined $label;
    }
  }
  return $retval;
}

sub build_class_name_hash {
  my $class_nodes = shift;
  my %classes;  # keyed by class name store left to right position

  for (my $i = 0; $i < $class_nodes->getLength(); $i++) {
    my $class = $class_nodes->item($i);
    my $class_name = $class->getAttribute("name");
    $classes{$class_name} = $i;
  }
  return \%classes;
}

sub parse_command_line {
    getopt('o');
    use vars qw($opt_o);
    $output_file = $opt_o if defined $opt_o;
}

1;

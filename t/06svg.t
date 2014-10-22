use strict;
use warnings;

use Test::More tests => 1;

use UML::Sequence::SimpleSeq;
use UML::Sequence;

my $outline     = UML::Sequence::SimpleSeq->grab_outline_text('t/washcar');
my $methods     = UML::Sequence::SimpleSeq->grab_methods($outline);

my $tree = UML::Sequence
    ->new($methods, $outline, \&UML::Sequence::SimpleSeq::parse_signature);

# run the seq2svg.pl script against washcar.xml from the distribution

open TESTSVG, "./seq2svg.pl t/washcar.xml |"
        or die "Couldn't run seq2svg.pl: $!\n";
my @test_svg = <TESTSVG>;
close TESTSVG;

my @correct_svg = <DATA>;

is_deeply(\@test_svg, \@correct_svg, "svg output");

__DATA__
<?xml version="1.0"?>
  <svg xmlns="http://www.w3.org/2000/svg" height="580" width="552">
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
    <text x="5" y="15">
        Wash Car
    </text>
<text y='40' x='30'>At Home</text>
  <rect style='fill: none' height='20' width='125' y='25' x='22' />
  <line style='stroke-dasharray: 4,4; ' fill='none' stroke='black' x1='92' y1='55' x2='92' y2='575' />
    <rect style='fill: white' height='500' width='15' y='55' x='84'/>

<text y='40' x='158'>Garage</text>
  <rect style='fill: none' height='20' width='125' y='25' x='150' />
  <line style='stroke-dasharray: 4,4; ' fill='none' stroke='black' x1='220' y1='95' x2='220' y2='575' />
    <rect style='fill: white' height='20' width='15' y='95' x='212'/>
    <rect style='fill: white' height='20' width='15' y='255' x='212'/>
    <rect style='fill: white' height='20' width='15' y='295' x='212'/>
    <rect style='fill: white' height='20' width='15' y='455' x='212'/>
    <rect style='fill: white' height='20' width='15' y='495' x='212'/>
    <rect style='fill: white' height='20' width='15' y='535' x='212'/>

<text y='40' x='286'>Kitchen</text>
  <rect style='fill: none' height='20' width='125' y='25' x='278' />
  <line style='stroke-dasharray: 4,4; ' fill='none' stroke='black' x1='348' y1='135' x2='348' y2='575' />
    <rect style='fill: white' height='100' width='15' y='135' x='340'/>
    <rect style='fill: white' height='20' width='15' y='175' x='350'/>
    <rect style='fill: white' height='20' width='15' y='215' x='350'/>

<text y='40' x='414'>Driveway</text>
  <rect style='fill: none' height='20' width='125' y='25' x='406' />
  <line style='stroke-dasharray: 4,4; ' fill='none' stroke='black' x1='476' y1='335' x2='476' y2='575' />
    <rect style='fill: white' height='20' width='15' y='335' x='468'/>
    <rect style='fill: white' height='20' width='15' y='375' x='468'/>
    <rect style='fill: white' height='20' width='15' y='415' x='468'/>

<line x1='100' y1='95' x2='213' y2='95' style='marker-end: url(#mArrow);' />
<text x='103' y='89'>retrieve bucket</text>
<line x1='100' y1='135' x2='341' y2='135' style='marker-end: url(#mArrow);' />
<text x='103' y='129'>prepare bucket</text>
<line x1='356' y1='165' x2='381' y2='165' />
<line x1='381' y1='165' x2='381' y2='185' />
<line x1='381' y1='185' x2='366' y2='185' style='marker-end: url(#mArrow);' />
<text x='384' y='175'>pour soap in bucket</text>
<line x1='356' y1='205' x2='381' y2='205' />
<line x1='381' y1='205' x2='381' y2='225' />
<line x1='381' y1='225' x2='366' y2='225' style='marker-end: url(#mArrow);' />
<text x='384' y='215'>fill bucket</text>
<line x1='100' y1='255' x2='213' y2='255' style='marker-end: url(#mArrow);' />
<text x='103' y='249'>get sponge</text>
<line x1='100' y1='295' x2='213' y2='295' style='marker-end: url(#mArrow);' />
<text x='103' y='289'>open door</text>
<line x1='100' y1='335' x2='469' y2='335' style='marker-end: url(#mArrow);' />
<text x='103' y='329'>apply soapy water</text>
<line x1='100' y1='375' x2='469' y2='375' style='marker-end: url(#mArrow);' />
<text x='103' y='369'>rinse</text>
<line x1='100' y1='415' x2='469' y2='415' style='marker-end: url(#mArrow);' />
<text x='103' y='409'>empty bucket</text>
<line x1='100' y1='455' x2='213' y2='455' style='marker-end: url(#mArrow);' />
<text x='103' y='449'>close door</text>
<line x1='100' y1='495' x2='213' y2='495' style='marker-end: url(#mArrow);' />
<text x='103' y='489'>replace sponge</text>
<line x1='100' y1='535' x2='213' y2='535' style='marker-end: url(#mArrow);' />
<text x='103' y='529'>replace bucket</text>
</svg>

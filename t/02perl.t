use strict;
use warnings;

use Test::More tests => 3;

BEGIN { use_ok('UML::Sequence::PerlSeq'); }

my $out_rec     = UML::Sequence::PerlSeq
                    ->grab_outline_text(qw(t/roller.methods t/roller));

chomp(my @correct_out = <DATA>);

is_deeply($out_rec, \@correct_out, "perl Dprof trace");

my $methods     = UML::Sequence::PerlSeq->grab_methods($out_rec);

my @correct_methods = (
"DiePair::new",
"Die::new",
"DiePair::roll",
"Die::roll",
"DiePair::total",
"DiePair::doubles",
"DiePair::to_string",
);

is_deeply($methods, \@correct_methods, "method list");

unlink "tmon.out";

__DATA__
main::BEGIN
   strict::import
      strict::bits
DiePair::BEGIN
   overload::import
      overload::OVERLOAD
DiePair::new
   Die::new
   Die::new
DiePair::roll
   Die::roll
   Die::roll
DiePair::total
DiePair::doubles
DiePair::to_string

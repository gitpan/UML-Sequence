use strict;
use warnings;

use Test::More tests => 3;

BEGIN { use_ok('UML::Sequence::SimpleSeq'); }

my $out_rec     = UML::Sequence::SimpleSeq->grab_outline_text('t/washcar');

my @correct_out = <DATA>;

unless (is_deeply($out_rec, \@correct_out, "simple outline read")) {
    local $" = "";
    diag("bad outline\n@$out_rec\n");
}

my $methods     = UML::Sequence::SimpleSeq->grab_methods($out_rec);
my @methods     = sort keys %$methods;

my @correct_methods = (
"At Home.Wash Car\n",
"Driveway.apply soapy water\n",
"Driveway.empty bucket\n",
"Driveway.rinse\n",
"Garage.close door\n",
"Garage.get sponge\n",
"Garage.open door\n",
"Garage.replace bucket\n",
"Garage.replace sponge\n",
"Garage.retrieve bucket\n",
"Kitchen.fill bucket\n",
"Kitchen.pour soap in bucket\n",
"Kitchen.prepare bucket\n",
);

unless (is_deeply(\@methods, \@correct_methods, "method list")) {
    local $" = "";
    diag("bad method list\n@methods\n");
}

__DATA__
At Home.Wash Car
    Garage.retrieve bucket
    Kitchen.prepare bucket
        Kitchen.pour soap in bucket
        Kitchen.fill bucket
    Garage.get sponge
    Garage.open door
    Driveway.apply soapy water
    Driveway.rinse
    Driveway.empty bucket
    Garage.close door
    Garage.replace sponge
    Garage.replace bucket

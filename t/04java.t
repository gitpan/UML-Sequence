use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('UML::Sequence::JavaSeq'); }

my $youre_brave = 1;

chomp(my $java_path = `which java`);
my $tools_jar;
my $java_failed = $?;
my $tool_failed = 0;

unless ($java_failed) {
    $tools_jar      = $java_path;
    my $count       = $tools_jar =~ s!/bin/java!!;
    $tool_failed    = 1 unless $count;
    $tools_jar      = "$tools_jar/lib/tools.jar";
    $tool_failed    = 1 unless (-f $tools_jar);
    $ENV{CLASSPATH} = "$tools_jar:.";
}

SKIP: {
    skip "No Java found",                           1 if $java_failed;
    skip "No tools.jar found, I tried: $tools_jar", 1 if $tool_failed;

    chdir "java";

    my $out_rec     = UML::Sequence::JavaSeq
                        ->grab_outline_text(qw(Hello.methods Hello));

    my @correct_out = <DATA>;

    is_deeply($out_rec, \@correct_out, "java sequence outline");

# This used to be in the test suite:
#    my $methods     = UML::Sequence::JavaSeq->grab_methods($out_rec);
# It is no longer included, because JavaSeq->grab_methods is inherited
# from SimpleSeq->grab_methods and so has already been tested in 01simple.t

}

__DATA__
Hello.main(java.lang.String[])
  helloHelper1:HelloHelper.<init>()
    helloHelper2:HelloHelper.<init>(java.lang.String)
  helloHelper2:HelloHelper.printIt(java.lang.String, float, java.lang.String[][], HelloHelper)

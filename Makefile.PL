use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my @executables;

use Config;
foreach my $source ('genericseq.source', 'seq2svg.source') {
    my    $script      = $source;
    $script            =~ s/\.source/.pl/;
    open  SCRIPT,       ">$script" or next;
    open  SOURCE,        "$source" or next;
    chmod 0755,          "$script";
    push @executables,   "$script";
    print SCRIPT "$Config{startperl}\n";
    while (<SOURCE>) {
        print SCRIPT;
    }
    close SCRIPT;
    close SOURCE;
}

WriteMakefile(
    'NAME'		=> 'UML::Sequence',
    'VERSION_FROM'	=> 'Sequence.pm', # finds $VERSION
    'PREREQ_PM'		=> { XML::DOM => 1.25 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?
      ( ABSTRACT_FROM   => 'Sequence.pm',
        AUTHOR          => 'Phil Crow <philcrow2000@yahoo.com>'
      )    :   ()
    ),
    'EXE_FILES'         => \@executables # [ 'genericseq.pl', 'seq2svg.pl' ]
);

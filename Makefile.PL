use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'UML::Sequence',
    'VERSION_FROM'	=> 'Sequence.pm', # finds $VERSION
    'PREREQ_PM'		=> { XML::DOM => 1.25 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?
      ( ABSTRACT_FROM   => 'Sequence.pm',
        AUTHOR          => 'Phil Crow <philcrow2000@yahoo.com>'
      )    :   ()
    ),
    'EXE_FILES'         => [ 'genericseq.pl', 'seq2svg.pl' ]
);

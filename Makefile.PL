use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my @executables;

print <<EOJ;
This distribution can sometimes be used to diagram Java programs by running
them.  For this to work, you must have the Sun SDK installed.  That SDK must
have a tools.jar, which must be in the classpath when you use
UML::Sequence::JavaSeq.  Further, the classpath must also include Seq.java
found in the java directory of the distribution.  See README
and samples/README for details.

During testing, I will try to find your SDK and its tools.jar, which I
will temporarily insert into the classpath.  If I can't do that, I will
skip the Java tests.
EOJ

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
    'VERSION_FROM'	=> 'lib/UML/Sequence.pm', # finds $VERSION
    'PREREQ_PM'		=> { XML::DOM   => 1.25,
                             Test::More => 0,}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?
      ( ABSTRACT_FROM   => 'lib/UML/Sequence.pm',
        AUTHOR          => 'Phil Crow <philcrow2000@yahoo.com>'
      )    :   ()
    ),
    'EXE_FILES'         => \@executables # [ 'genericseq.pl', 'seq2svg.pl' ]
);

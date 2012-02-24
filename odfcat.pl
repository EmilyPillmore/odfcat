#!/usr/bin/perl
use warnings; 
use strict;
use XML::Simple;
use Getopt::Long;
use Pod::Usage;

$|++;
my $verbose;
my ($help, $man);
Getopt::Long::GetOptions ("quiet" => \$verbose,
						  "verbose" => sub{$verbose = 1;},
						  "help" => \$help,
						  "man" => \$man);
						  			
Pod::Usage::pod2usage( -verbose => 1 ) if ($help);
Pod::Usage::pod2usage( -verbose => 2 ) if ($man);	  

# Fetches file and checks to make sure it exists, then Unzips it using unzip utility and extracts to temporary directory
@ARGV or Pod::Usage::pod2usage( -verbose => 1 );
my $file = $ARGV[0];
print $0 . ' :: Fetching - ' . $file . "\n";
	
qx(if [ ! -f $file ];
    then 
	echo "$0 :: File not found!"
    else
	if [ ! -d /tmp/.odfcat/ ];
	 then
		mkdir /tmp/.odfcat/
		unzip $file -d /tmp/.odfcat/
	fi	
	unzip $file -d /tmp/.odfcat/
   fi);
	
main();
	
# Cleanup and exit
print "\n$0 :: Finished!\n";
qx(/bin/rm -rf /tmp/.odfcat);
exit 0;

# Uses XML::Simple on the two main content and information schema files in odf to parse necessary information and print - how much depending on verbosity
sub main {
	my $xml = XMLin("/tmp/.odfcat/meta.xml");	
	my $content = XMLin("/tmp/.odfcat/content.xml");
	
	if ($verbose == 0) {
		print "\nVersion :: " . $xml->{'office:version'} . "\n";
		print "Creator :: " . $xml->{'office:meta'}->{'meta:initial-creator'} . "\n";
		print "Creation Date :: " . $xml->{'office:meta'}->{'dc:date'} . "\n";
		print "Last Edited :: " . $xml->{'office:meta'}->{'meta:editing-duration'} . "\n";
		print "Word Count :: " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'} . "\n";
	}
	else {
		print "\nVersion :: " . $xml->{'office:version'} . "\n";
		print "Creator :: " . $xml->{'office:meta'}->{'meta:initial-creator'} . "\n";
		print "Creation Date :: " . $xml->{'office:meta'}->{'dc:date'} . "\n";
		print "Last Edited :: " . $xml->{'office:meta'}->{'meta:editing-duration'} . "\n";
		print "Word Count :: " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'} . "\n";	
		print "Page Count :: " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:page-count'} . "\n";
		print "Character Count :: " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:character-count'} . "\n";
		
# Content printing is available, but not recommended for large documents		
		print "Print content? [Y/n]: ";
		chomp(my $in = <STDIN>);
		if ($in eq "Y") {
			print "Printing Content :: \n\t" . $content->{'office:body'}->{'office:text'}->{'text:p'}->{'content'} . "\n";
		}
		else {return};
	}
}
__END__

=head1 NAME

Odfcat - simple ODF parsing tool to display necessary information from Open Document files.

=head1 SYNOPSIS

Use:

    odfcat [--help/man] 
    odfcat [--verbose/-v] [file.odt]

Examples:

    odfcat -v [file] | odfcat --verbose [file.odt]
    odfcat --help | --man
    
    Default quiet verbosity.

=head1 DESCRIPTION

This script uses the XML::Simple module to parse Open Document files for basic information associated with user, word count, page count, version, edit dates, and other criteria. It is designed to be used in the same way you would 'cat' a file, and content is readily displayed if necessary.

=back

=head1 AUTHOR

Wyatt Pillmore, E<lt>wpillmore@gmail.comE<gt>.

=head1 COPYRIGHT

This program is distributed under the SHUT UP AND TAKE MY MONEY license.

=head1 DATE

19-2-2012

=cut
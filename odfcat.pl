#!/usr/bin/perl
use warnings; 
use strict;
use XML::Simple;
use Getopt::Long;
use Pod::Usage;

$|++;
my $verbose;
Getopt::Long::GetOptions ( "quiet" => \$verbose,
		  	   "verbose" => sub{ \$verbose = 1; },
			   "file=s" => my $output,
			   "as-xml" => my $flag,
			   "help" => my $help,
			   "man" => my $man );
						  			
Pod::Usage::pod2usage( -verbose => 1 ) if $help;
Pod::Usage::pod2usage( -verbose => 2 ) if $man;

# Fetches file and checks to make sure it exists, then Unzips it using unzip utility and extracts to temporary directory
@ARGV or Pod::Usage::pod2usage( -verbose => 1 );
my $file = $ARGV[0];

die "$0 :: File not found!" unless -e $file;
print "$0 :: extracting - $file\n";
	! -d '/tmp/.odfcat'
 		? qx(mkdir /tmp/.odfcat/ &&
	  	unzip $file -d '/tmp/.odfcat/')
		: qx(unzip $file -d '/tmp/.odfcat/');

$flag ? as_xml() : main();
	
# Cleanup and exit
print "\n$0 :: Finished!\n";
qx(/bin/rm -rf /tmp/.odfcat/);
exit 0;

# Uses XML::Simple on the two main content and information schema files in odf to parse necessary information and print - how much depending on verbosity
sub main {
	my $xml = XMLin("/tmp/.odfcat/meta.xml");	
	my $content = XMLin("/tmp/.odfcat/content.xml");
	
    	if($output) {
    		open(OUTFILE, '>', $output) or die "$0 :: Could not open file. Does it exist, or does it not allow Write Access?";
    		! $verbose == 1
			? print OUTFILE "\nVersion :: $xml->{'office:version'}\nCreator :: $xml->{'office:meta'}->{'meta:initial-creator'}\nCreation Date :: $xml->{'office:meta'}->{'dc:date'}\nLast Edited :: $xml->{'office:meta'}->{'meta:editing-duration'}\nWord Count :: $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'}\n"
			: print OUTFILE "\nVersion :: $xml->{'office:version'}\nCreator :: $xml->{'office:meta'}->{'meta:initial-creator'}\nCreation Date :: $xml->{'office:meta'}->{'dc:date'}\nLast Edited :: $xml->{'office:meta'}->{'meta:editing-duration'}\nWord Count :: $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'}\nPage Count :: $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:page-count'}\nCharacter Count :: $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:character-count'}\n";
		close OUTFILE;
		return;
	}
	if( ! $verbose == 1) { 
		return print "\nVersion :: $xml->{'office:version'}\nCreator :: $xml->{'office:meta'}->{'meta:initial-creator'}\nCreation Date :: $xml->{'office:meta'}->{'dc:date'}\nLast Edited :: $xml->{'office:meta'}->{'meta:editing-duration'}\nWord Count :: $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'}\n";
	}
	else {
		print "\nVersion :: $xml->{'office:version'}\nCreator :: $xml->{'office:meta'}->{'meta:initial-creator'}\nCreation Date :: $xml->{'office:meta'}->{'dc:date'}\nLast Edited :: $xml->{'office:meta'}->{'meta:editing-duration'}\nWord Count :: $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'}\nPage Count :: $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:page-count'}\nCharacter Count :: $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:character-count'}\n";
		print "\nPrint content? [Y/n]: ";
		<STDIN> =~ /^y\n/i
			? print "Printing Content :: \n\t$content->{'office:body'}->{'office:text'}->{'text:p'}->{'content'}\n"
			: return;
	}
	#cleanup of unnecessary local variables
	undef $xml, $content, $verbose, $output;
	return;
}

sub as_xml { 
	die "Please supply a file to write to if you want XML output." unless $output;
	
	my $xml = XMLin("/tmp/.odfcat/meta.xml");	
	my $content = XMLin("/tmp/.odfcat/content.xml");
	
	open(OUTFILE, '>', $output);
		print OUTFILE $xml;
		print OUTFILE $content;
	close OUTFILE;
	return;
}	

__END__

=head1 NAME

Odfcat - simple ODF parsing tool to display necessary information from Open Document files.

=head1 SYNOPSIS

Use:

    odfcat [--help|man] 
    odfcat [--verbose|-v] [file.odt]

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
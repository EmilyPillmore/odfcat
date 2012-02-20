#!/usr/bin/perl
use warnings; 
use XML::Simple;
use Getopt::Long;
use Switch;

$|++;
our $verbose = 0;
our $result = GetOptions ("quiet" => \$verbose,
			  "verbose" => sub{$verbose = 1;},
			  "help" => sub{$verbose = 2;});
						  
my $file = $ARGV[0];
print 'odfcat::Fetching - ' . $file . "\n";
&init();

# ------------ Fetches file and checks to make sure it exists, then Unzips it using unzip utility and extracts to temporary directory ---------------- #
sub init {
	qx(if [ ! -f $file ];
		then 
			echo odfcat :: File not found!;
		else
			if [ ! -d /tmp/.odfcat ];
			 then
				mkdir /tmp/.odfcat;
				unzip $file -d /tmp/.odfcat/;
			fi;
			
			unzip $file -d /tmp/.odfcat;
		fi;);
	
# ------------ Checks verbose setting as set by our flags and calls appropriate subroutine ------------- #
	if($verbose == 2) {
		&help();
	}
	else {
		&main();
	}
# ------------ Cleanup and exit ------------- #	
	print "\nodfcat :: Finished!\n";
	qx(/bin/rm -rf /tmp/.odfcat;);
	exit(0);
}

# ------------- TODO: Getopts help and how to use. ------------- #
sub help {
	
}

# ------------- Uses XML::Simple on the two main content and information schema files in odf to parse necessary information and print - how much depending on verbosity -------------- #
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
		
# -------------- Content printing is available, but not recommended for large documents --------------- #		
		print "Print content? [Y/n]: ";
		my $in = <STDIN>;
		chomp $in;
		if ($in eq "Y") {
			print "Printing Content :: \n" . $content->{'office:body'}->{'office:text'}->{'text:p'}->{'content'} . "\n";
		}
		else {return};
	}
}
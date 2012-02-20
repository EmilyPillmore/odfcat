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
					  	 
sub init {
	qx(if [ ! -f $file ];
		then 
			echo odfcat :: File not found!;
		else
			if [ ! -d /tmp/.odfcat ];
			 then
				mkdir /tmp/.odfcat;
				unzip -o $file -d /tmp/.odfcat/;
			fi;
			
			unzip -o $file -d /tmp/.odfcat;
		fi;);
	
	switch($verbose) {
		case 0 {
			&quiet();
		}
		case 1 {
			&verbose();
		}
		case  2 {
			&help();
		}
		
	}
	print "\nodfcat :: Finished!\n";
	qx(rm -rf /tmp/.odfcat;);
	exit(0);
}

sub tolog {
	print shift () . "\n";
}

sub help {
	
}

sub quiet {
	
	my $xml = XMLin("/tmp/.odfcat/meta.xml");
	print "\nCreator :: " . $xml->{'office:meta'}->{'meta:initial-creator'} . "\n";
	print "Creation Date :: " . $xml->{'office:meta'}->{'dc:date'} . "\n";
	print "Last Edited :: " . $xml->{'office:meta'}->{'meta:editing-duration'} . "\n";
	print "Word Count :: " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'} . "\n";
}

sub verbose {
	my $xml = XMLin("/tmp/.odfcat/meta.xml");	
	my $content = XMLin("/tmp/.odfcat/content.xml");
	
	print "Version :: " . $xml->{'office:version'} . "\n";
	print "\nCreator :: " . $xml->{'office:meta'}->{'meta:initial-creator'} . "\n";
	print "Creation Date :: " . $xml->{'office:meta'}->{'dc:date'} . "\n";
	print "Last Edited :: " . $xml->{'office:meta'}->{'meta:editing-duration'} . "\n";
	print "Word Count :: " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'} . "\n";
	print "Page Count :: " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:page-count'} . "\n";
	print "Character Count :: " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:character-count'} . "\n";
	
	print "Print content? [Y/n]: ";
	if (<STDIN> eq "Y") {
		print "Printing Content :: \n" . $content->{'office:body'}->{'office:text'}->{'text:p'}->{'content'} . "\n";
	}
	else {return};
}
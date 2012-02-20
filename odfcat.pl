#!/usr/bin/perl
use warnings; 
use XML::Simple;
use Data::Dumper;
use Getopt::Long;

$|++;
my $file = $ARGV[0];
print 'odfcat::Fetching - ' . $file . "\n";
&init();
					  	 
sub init {
	qx(if [ ! -f $file ];
		then 
			echo odfcat :: File not found!;
		else
			echo odfcat :: Extracting contents ... ;
			if [ ! -d /tmp/.odfcat ];
			 then
				mkdir /tmp/.odfcat;
				echo odfcat :: Unzipping contents ... ;
				unzip $file -d /tmp/.odfcat/;
			fi;
			
			echo odfcat:: Unzipping contents ... ;
			unzip $file -d /tmp/.odfcat;
		fi;);
		
	&verbose();
	qx(rm -rf /tmp/.odfcat;);
	exit(0);
}

sub tolog {
	print shift () . "\n";
}

sub help {
	
}

sub verbose {
	my $xml = XMLin("/tmp/.odfcat/meta.xml");	
	my $content = XMLin("/tmp/.odfcat/content.xml");
	
	print "Version - " . $xml->{'office:meta'}->{'meta:generator'} . " " . $xml->{'office:version'} . "\n";
	print "Creator - " . $xml->{'office:meta'}->{'meta:initial-creator'} . "\n";
	print "Creation Date - " . $xml->{'office:meta'}->{'dc:date'} . "\n";
	print "Last Edited - " . $xml->{'office:meta'}->{'meta:editing-duration'} . "\n";
	print "Word Count - " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'} . "\n";
	print "Page Count - " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:page-count'} . "\n";
	print "Character Count - " . $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:character-count'} . "\n";
	
	print "Print content? [Y/n]: ";
	if (<STDIN> =~ /(Y|y|yes|Yes|YEs|YES|)/i) {
		print "Printing Content - \n \n" . $content->{'office:body'}->{'office:text'}->{'text:p'}->{'content'} . "\n";
	}
	else {
		print "odfcat :: Finished!";
	}
}
#!/usr/bin/perl
use warnings; 
use strict;
use XML::Simple;
use Data::Dumper;
use Getopt::Long;

$|++;
my $file = $ARGV[0];
print '::Fetching - ' . $file . "\n";
&init();
					  	 
sub init {
	qx(if [ ! -f $file ];
		then 
			echo '$0 :: File not found!';
		else
			echo '$0 :: Extracting contents ... ';
			if [ ! -d ~/.odfcat ];
			 then
				mkdir ~/.odfcat;
				echo '$0 :: Unzipping contents ... ';
				unzip $file -d ~/.odfcat;
				chmod 777 -R ~/.odfcat;
			fi;
			echo '$0 :: Unzipping contents ... ';
			unzip $file -d ~/.odfcat;
			chmod 777 -R ~/.odfcat;
			
		fi;);
	my %xml = \&main();
	print %xml;
	
}

sub tolog {
	print shift () . "\n";
}

sub help {
	
}

sub main {
	my $xml = XMLin("~/.odfcat/meta.xml");
	my %xml = ( "version" => "$xml->{'office:meta'}->{'meta:generator'} " . $xml->{'office:version'},
			 "creator " => $xml->{'office:meta'}->{'meta:initial-creator'},
			 "cdate" => $xml->{'office:meta'}->{'dc:date'},
			 "edited" => $xml->{'office:meta'}->{'meta:editing-duration'},
			 "wcount" => $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'},
			 "pcount" => $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:page-count'},
			 "ccount" => $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:character-count'},
			 "content" => $xml->{'office:body'}->{'office:text'}->{'text:p'}->{content},
	);
	return %xml;
}
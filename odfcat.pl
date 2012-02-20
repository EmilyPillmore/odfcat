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
			echo 'odfcat :: File not found!';
		else
			echo odfcat :: Extracting contents ... 
			if [ ! -d /tmp/.odfcat ];
			 then
				mkdir /tmp/.odfcat;
				echo odfcat :: Unzipping contents ... 
				unzip $file -d /tmp/.odfcat/;
			fi;
			
			echo odfcat:: Unzipping contents ... 
			unzip $file -d /tmp/.odfcat;
		fi;);
		
	my %xml = \&main();
	for my $keys (keys %xml) {
		print "$keys -> $xml{$keys}\n";
	}
	qx(rm -rf /home/.odfcat;);
	print "odfcat :: Finished!\n";
	exit(0);
}

sub tolog {
	print shift () . "\n";
}

sub help {
	
}

sub main {
	my $file = "/tmp/.odfcat/meta.xml";
	my $xml = XMLin($file);	
	my %xmlin = ("version" => $xml->{'office:meta'}->{'meta:generator'} . $xml->{'office:version'},
			   "creator"  => $xml->{'office:meta'}->{'meta:initial-creator'},
			   "cdate" => $xml->{'office:meta'}->{'dc:date'},
			   "edited" => $xml->{'office:meta'}->{'meta:editing-duration'},
			   "wcount" => $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:word-count'},
			   "pcount" => $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:page-count'},
			   "ccount" => $xml->{'office:meta'}->{'meta:document-statistic'}->{'meta:character-count'},
			   "content" => $xml->{'office:body'}->{'office:text'}->{'text:p'}->{content},
			);
	return $xmlin;
}
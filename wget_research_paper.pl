################
# Required : xclip, curl
#######

#!/bin/env perl
use strict;
use warnings;

# ------------------------------------ USAGE --------------------------------- #
sub usage {
	my $name = $0;
	print "\n usage : $name HANDLED_WEBSITE IDFROMWEBSITE\n"; 
	print "HANDLED_WEBSITE : a(cm) , s(pringer) \n";
	print "output : the file DATE_TITLE.pdf  + bibtex in the clipboard \n";

	exit 1;
}

# --------------------------------- ARGUMENTS -------------------------------- #
my $num_args = $#ARGV + 1;  
if ($num_args != 2) { 
	usage();
}


# -------------------------------- GLOBAL VAR -------------------------------- #
my $website = $ARGV[0];
my $idpaper = $ARGV[1];
#my $idpaper=1454125;
my $date="1800";
my $name="crazypaper";
my $bib = "";

#usefull for info_from_bibtexline, to handle multiline title
my $restitlesvg = "";

# -------------------------------- TOOLS -------------------------------- #
# info_from_bibtexline
# modify global var name and title
# request 1 ARG : the line to explore
sub info_from_bibtexline {
	my $line = $_[0];	

	#found TITLE (handle multiline title)
	if ( $line =~ m/^[\ ]*title[^=]*=[^\{]*\{([^\}]+)/ ) {
		$restitlesvg = $1;
		$restitlesvg =~ s/},//;
		if ( $line =~ /^[\ ]*title[^=]*=[^\{]*\{([^\}]+)\}/ ) {
			$name=$restitlesvg;
			$restitlesvg = "";
		}
	} elsif ( $restitlesvg ne "" && $line =~ m/^[\ ]*([^\}]+)/ ) {
		my $found = $1;
		$found =~ s/^\s+//g;
		$restitlesvg .= " " . $found;
		$restitlesvg =~ s/},//;
		if ( $line =~ /^([^\}]+)/ ) {
			$name=$restitlesvg;
			$restitlesvg = "";
		}
	}
	# found DATE
	if ( $line =~ m/year[^=]*=[^\}]*\{([^\}]+)\}/ ) {
		$date = "$1";
	}

}


# -------------------------------- ACM -------------------------------- #
# ACM_get_bibtex
# modify $bib, $name, $title
sub acm_get_bibtex {
	$bib ="";
	my $url = "https://dl.acm.org/exportformats.cfm?id=${idpaper}&expformat=bibtex";
	my $resbib = `curl "$url"`;
	my @tresbib = split('\n',$resbib);
	my $isbibtex=0;
	# the bibtex is between <PRE id="idpaper"> ... </pre> 
	READLINE: foreach my $line (@tresbib){
		if($isbibtex == 1){
			if($line =~ m/<\/pre>/) { # end of bibtex
				$isbibtex = 0;
				last READLINE; # we already caught one bibtex, stop foreach
			} else {
				$bib = $bib.$line."\n";
				#we have to extract name and date
				info_from_bibtexline $line;
			}	
		} else {
			if ( $line =~ m/^<PRE\ id=\"${idpaper}\">/ ) { # begin of bibtex
				$isbibtex = 1;
			}
		}
	}
}


# ACM_get pdf
sub acm_get_pdf {
#-L for follow redirection
	my $url="http://dl.acm.org/ft_gateway.cfm?id=$idpaper";
	`curl -o "${date}_${name}.pdf" -L "$url"`;
}

# -------------------------------- SPRINGER -------------------------------- #
sub springer_get_bibtex {
	print "$idpaper";
	my $url="http://link.springer.com/export-citation/chapter/${idpaper}.bib";
	my $resbib = `curl "$url"`;
	my @tresbib = split('\n',$resbib);
	#gives the bibtex already well (raw) formated !
	#we have to extract name and date
	READLINE: foreach my $line (@tresbib){
		info_from_bibtexline $line;
		$bib = $bib.$line."\n";
	}
}
sub springer_get_pdf {
	my $url="http://link.springer.com/content/pdf/$idpaper"; 
	`curl -o "${date}_${name}.pdf" -L "$url"`;
}


# ------------------------------- ENTRY POINT  ------------------------------- #

if ($website eq "a") { #ACM
	acm_get_bibtex();
	acm_get_pdf();
} elsif ($website eq "s") { #SPRINGER
	springer_get_bibtex();
	springer_get_pdf();
} else {
	print STDERR "ERROR : website unknown \n";
	exit 1;
}


print "#################### PDF ########################## \n ";
print "Downloading ${date}_${name}.pdf \n\n";

print "#################### BIBTEX ########################## \n \n";
print $bib;
print "\n \n";


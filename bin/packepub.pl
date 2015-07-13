#!/usr/bin/perl
use Getopt::Long;
use XML::Parser;
use File::Basename;
use File::Copy qw(copy move);
use File::Path 'rmtree';
use DateTime;
use Cwd;
use I18N::Langinfo qw(langinfo CODESET);
use Encode qw(decode);
use Archive::Zip;
binmode STDOUT, ":utf8";

use constant {
	NONE => 0,
	META => 100,
	MANIFEST => 200,
	SPINE => 300,
	DCTERMS => 101,
	NAV => 400,
	NAVUL => 401,
	NAVLI => 402,
	NAVLIA => 403,
};

$state = NONE;

$codeset = langinfo(CODESET);
@ARGV = map { decode $codeset, $_ } @ARGV;

# Get command line arguments
$result = GetOptions("i=s" => \$newid);
$filename = $ARGV[0];

if($filename eq '') {
	print "Create EPUB from files in directory\n";
	print "usage: packepub <filename>\n";
	print "\n";
	print "packepub looks at the current directory for 'mimetype' and META-INF if they don't exist it will issue an error and exit\n";
	print "It checks the META-INF/container.xml for the OPF file and then looks at the OPF file.\n";
	print "Files are packed according to OPF contents.\n";
	print "OPF creation time will be changed to current time\n";
	exit;
}

# Check if file has EPUB extenstion and remove it if needed
$filename =~ s/.epub//i;

if(! -e 'mimetype') {
	print "mimetype does not exist\n";
	exit;
}

if(! -e 'META-INF/container.xml') {
	print "Can't find META-INF/container.xml\n";
	exit;
}

# Find what file is used as the packge file (OPF)
$cparse = new XML::Parser(Handlers => {Start => \&hdl_start });
$cparse->parsefile('META-INF/container.xml');

sub hdl_start {
	my ($p, $elt, %atts) = @_;
	if($elt eq 'rootfile') {
		$rootfile = $atts{'full-path'};
		print "#Root file: $rootfile\n";
		handleOPF();
	}
}

sub handleOPF() {
	$outzip = Archive::Zip->new();
	$outzip->addFile("mimetype", 'mimetype', 0);
	$outzip->addTree("META-INF", 'META-INF');
	print "Adding $rootfile\n";
	WriteOPF($rootfile);
	$outzip->addFile("$rootfile", $rootfile);
	$parseopf = new XML::Parser(Handlers => {'Start' => \&opf_packstart});
	print "#Pack handleOPF $rootfile\n";
	($n, $oepbsdir, $ext) = fileparse($rootfile);
	$parseopf->parsefile("$rootfile");
	unless($outzip->writeToFileNamed("$filename.epub") == AZ_OK) {
		print "Error writing to $filename.epub\n";
	}
}

sub opf_packstart {
	my ($p, $elt, %atts) = @_;

	if($elt eq 'metadata') {
		$state = META;
	}
	elsif($elt eq 'manifest') {
		$state = MANIFEST;
	}
	elsif($elt eq 'spine') {
		$state = SPINE;
	}
	if($state == META) {
		if($atts{'name'} eq 'cover') {
			$coverid = $atts{'content'};
		}
	}
	if($state == MANIFEST) {
		if($elt eq 'item') {
			$ref = $atts{'href'};
			print "Adding file: $oepbsdir$ref\n";
			$outzip->addFile("$oepbsdir$ref", "$oepbsdir$ref");
		}
	}
}

# Create new OPF
# Change modification time to current time optionaly change book id
sub WriteOPF {
	$opf = shift;

	$tmpopf = "$opf.tmp";
	open(IN, $opf);
	binmode IN, ":utf8";
	open(OUT, ">$tmpopf");
	binmode OUT, ":utf8";

	$state = 0;
	$noprint = 0;
	while(<IN>) {
		if($state == NONE) {
			if(/unique-identifier=\"(.*?)\"/) {
				$bookid = $1;
			}
			if(/metadata/) {
				$state = META;
			}
			elsif(/manifest/) {
				$state = MANIFEST;
			}
			else {
				print OUT $_;
			}
		}
		if($state == META) {
			if(/id="(.*?)"/) {
				if($1 eq $bookid) {	# Change book id if needed
					if($newid) {
						print OUT "<dc:identifier id=\"$bookid\">$newid</dc:identifier>\n";
					}
					else {
						print OUT $_;
					}
				}
				else {
					print OUT $_;
				}
			}
			elsif(/dcterms:modified/) {
				$dt = DateTime->now();
				$dtstr = $dt->ymd('-')  . "T" . $dt->hms(':') . "Z";
				print "dtstr: $dtstr\n";
				print OUT "<meta property=\"dcterms:modified\">$dtstr</meta>\n";
				$wrotemodtime = 1;
			}
			else {
				if(/<\/metadata/) {
					if($wrotemodtime == 0) {	# Add modification time
						$dt = DateTime->now();
						$dtstr = $dt->ymd('-')  . "T" . $dt->hms(':') . "Z";
						print "dtstr: $dtstr\n";
						print OUT "<meta property=\"dcterms:modified\">$dtstr</meta>\n";
						$wrotemodtime = 0;
					}
				}
				print OUT $_;
			}
			if(/<\/metadata/) {
				$state = NONE;
			}
		}
		if($state == MANIFEST) {
			if(/spine/) {
				$state = SPINE;
			}
			else {
				print OUT $_;
			}
		}
		if($state == SPINE) {
			print OUT $_;
			if(/\/spine/) {
				$state = NONE;
			}
		}
	}
	close(OUT);
	close(IN);
	copy($tmpopf, $opf);
}


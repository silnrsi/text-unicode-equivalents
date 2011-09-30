use strict;
use utf8;
use Getopt::Std;
use Text::Unicode::Equivalents qw( all_strings );

our ($opt_h, $opt_o, $opt_t, $VERSION);
$VERSION = 0.3;

my $ignore;

getopts('ho:t');

die <<"EOF" if $opt_h;

ShowEquivalents -- list canonically equivalent sequences for a given sequence of codepoints.

Synopsis:
    ShowEquivalents -h
    ShowEquivalents [-t] [-o outfile] [ USV ]+

-h generates this help message.
-t trace computation
-o In addition to writing USVs to STDOUT, creates output file containing 
   UTF-8 strings

Unicode Scalar Values (USVs) are given as space-separated hex numbers 
(no leading U+) either on the command line or read from STDIN. 

The purpose of this program is primarily to demonstrate use of 
Text::Unicode::Equivalents. For example, the command 'ShowEquivalents 212B' 
generates the following output:

    --------- 212B:
    0041 030A
    00C5
    212B
    ---------

Version $VERSION
EOF

if ($opt_o)
{
    open OUT, ">:utf8", $opt_o or die "Couldn't open '$opt_o' for writing. $!\n";
    print OUT "\x{FEFF}";	# UTF-8 signature
}

if ($#ARGV >= 0)
{
	my $s = pack("U*", map {hex} @ARGV);
	print "--------- ", join(' ', @ARGV), ":\n";
	print OUT "--------- ", join(' ', @ARGV), ":\n" if $opt_o;
	my $l = all_strings($s, $opt_t);
	foreach $s (sort @{$l})
	{
		map {printf "%04X ", $_} unpack("U*", $s);
		print "\n";
		print OUT "$s\n" if $opt_o;
	}
}
else
{
	while(<STDIN>)
	{
		if (m/^#/)
		{
			print;
			next;
		}
		
		chomp;
		
		my $s = pack("U*", map {hex} split);
		print "--------- $_:\n";
		print OUT "--------- $_:\n" if $opt_o;
		my $l = all_strings($s, $opt_t);
		foreach $s (sort @{$l})
		{
			map {printf "%04X ", $_} unpack("U*", $s);
			print "\n";
			print OUT "$s\n" if $opt_o;
		}
		print "---------\n" if -t STDIN;
		print OUT "---------\n" if $opt_o;
	}
}
close OUT if $opt_o;

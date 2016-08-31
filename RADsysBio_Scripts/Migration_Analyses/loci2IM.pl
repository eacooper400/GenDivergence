#!/usr/bin/perl -w
#
# loci2IM.pl
#
# Convert the file with the loci into IMa2 input format
#
# October 2, 2013

use strict;

# Get all of the necessary input information from the command line
my ($USAGE) = "$0 <input.loci> <output.IM.infile> <pops> <num.loci> <pop sizes> <mutation model> <inheritance scalar>\n";
unless (@ARGV) {
  print $USAGE;
  exit;
}
my ($input, $output, $poplist, $numloci, $sizelist, $mutmodel, $iscalar) = @ARGV;

# Open the outfile and print the first 5 lines of the IMa2 input file
my @pops = split(/,/, $poplist);
my @sizes = split(/,/, $sizelist);
my $numpops = scalar @pops;
open (OUT, ">$output") || die "\nUnable to open the file $output!\n";
print OUT "\#", " RAD seqeuence data for ", $numloci, " loci in ", $numpops, " populations\n";
print OUT $numpops, "\n";
print OUT "@pops\n";
print OUT "(((1,2):4,0):5,3):6\n";
print OUT $numloci, "\n";

# Now reads through the input file and print all of the locus by locus information
open (IN, $input) || die "\nUnable to open the file $input!\n";
my $headline = '';
my @datalines = ();
my $seqlength = 0;
while (<IN>) {
  chomp $_;
  if ($_ =~ /^Locus/) {
    unless ((scalar @datalines) == 0) {
      print OUT $headline, $seqlength, " ", $mutmodel, " ", $iscalar, "\n";
      foreach my $dline (@datalines) {
	print OUT $dline, "\n";
      }
    }
    $headline = '';
    @datalines = ();
    my $seqlength = 0;

    $_ =~ s/\s//g;
    $headline .=  $_ . " ";
    $headline .=  "@sizes" . " ";
  } else {
    $seqlength = length($_) - 10;
    push (@datalines, $_);
  }
}
print OUT $headline, " ", $seqlength, " ", $mutmodel, " ", $iscalar, "\n";
foreach my $dline (@datalines) {
  print OUT $dline, "\n";
}
close(IN);
close(OUT);

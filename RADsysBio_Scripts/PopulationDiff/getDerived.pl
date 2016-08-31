#!/usr/bin/perl -w
#
# getDerived_alleles.pl
#
# Find derived and ancestral alleles using Russells as outgroup
#
# September 30, 2013

use strict;

# Open the input and output files
my ($USAGE) = "$0 <input.filtered> <output.derived>\n";
unless (@ARGV) {
  print $USAGE;
  exit;
}
my ($input, $output) = @ARGV;

open (IN, $input) || die "\nUnable to open the file $input!\n";
open (OUT, ">$output") || die "\nUnable to open the file $output!\n";

print OUT "CHROM", "." , "POS", "\tANC\tDER\tMAK_DER\tSA_DER\tUGI_DER\n";

while (<IN>) {
  chomp $_;
  if ($_ =~ /^CHROM/) {
    next;
  }
  my @info = split(/\t/, $_);
  my $ancs = '';
  my $der = '';
  
  if ($info[6] == 0) {
    $ancs = $info[1];
    $der = $info[2];
    print OUT $info[0], "\t", $ancs, "\t", $der, "\t", $info[3], "\t", $info[4], "\t", $info[5], "\n";
  } elsif ($info[6] == 1) {
    $ancs = $info[2];
    $der = $info[1];
    print OUT $info[0], "\t", $ancs, "\t", $der, "\t", 1-$info[3], "\t", 1-$info[4], "\t", 1-$info[5], "\n";
  } else {
    next;
  }
}
close(IN);
close(OUT);
exit;
  

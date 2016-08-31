#!/usr/bin/perl -w
#
# AFS_derived.pl
#
# Find the number of SNPs in each MAF bin for each the 3 populations, to plot as Allele Frequency Spectrum
#
# August 14, 2013

use strict;

# Take the names of the input and output files from the command line
my ($USAGE) = "$0 <input.alleles.txt> <output_afs.bins>\n";
unless (@ARGV) {
  print $USAGE;
  exit;
}
my ($input, $output) = @ARGV;

# Create 3 seperate hashes with 10 bins for each population
my %Makira = (
	      '0' => 0,
	      '0.05' => 0,
	      '0.10' => 0,
	      '0.15' => 0,
	      '0.20' => 0,
	      '0.25' => 0,
	      '0.30' => 0,
	      '0.35' => 0,
	      '0.40' => 0,
	      '0.45' => 0,
	      '0.50' => 0,
	      '0.55' => 0,
	      '0.60' => 0,
	      '0.65' => 0,
	      '0.70' => 0,
	      '0.75' => 0,
	      '0.80' => 0,
	      '0.85' => 0,
	      '0.90' => 0,
	      '0.95' => 0
	      );
my %SA = (
	      '0' => 0,
	      '0.05' => 0,
	      '0.10' => 0,
	      '0.15' => 0,
	      '0.20' => 0,
	      '0.25' => 0,
	      '0.30' => 0,
	      '0.35' => 0,
	      '0.40' => 0,
	      '0.45' => 0,
	      '0.50' => 0,
	      '0.55' => 0,
	      '0.60' => 0,
	      '0.65' => 0,
	      '0.70' => 0,
	      '0.75' => 0,
	      '0.80' => 0,
	      '0.85' => 0,
	      '0.90' => 0,
	      '0.95' => 0
	      );
my %Ugi = (
	      '0' => 0,
	      '0.05' => 0,
	      '0.10' => 0,
	      '0.15' => 0,
	      '0.20' => 0,
	      '0.25' => 0,
	      '0.30' => 0,
	      '0.35' => 0,
	      '0.40' => 0,
	      '0.45' => 0,
	      '0.50' => 0,
	      '0.55' => 0,
	      '0.60' => 0,
	      '0.65' => 0,
	      '0.70' => 0,
	      '0.75' => 0,
	      '0.80' => 0,
	      '0.85' => 0,
	      '0.90' => 0,
	      '0.95' => 0
	      );
my @keys = keys %Makira;

# Open the input and output files
open (IN, $input) || die "\nUnable to open the file $input!\n";
open (OUT, ">$output") || die "\nUnable to open the file $output!\n";

# Read through the input file one line at a time, and bin each SNP
while (<IN>) {
  chomp $_;
  if ($_ =~ /^CHROM/) {
    next;
  }
  my @info = split(/\t/, $_);
  foreach my $key (@keys) {
    if (($info[3] >= $key) && ($info[3] < ($key + 0.05))) {
      $Makira{$key} += 1;
    }
    if (($info[4] >= $key) && ($info[4] < ($key + 0.05))) {
      $SA{$key} += 1;
    }
    if (($info[5] >= $key) && ($info[5] < ($key + 0.05))) {
      $Ugi{$key} += 1;
    }
  }
}
close(IN);

# Print the final counts for each bin to the output file
my @sorted = sort {$a <=> $b} @keys;
foreach my $s (@sorted) {
  print OUT $s, '-', ($s+0.05), "\t", $Makira{$s}, "\t", $SA{$s}, "\t", $Ugi{$s}, "\n";
}
close(OUT);
exit;

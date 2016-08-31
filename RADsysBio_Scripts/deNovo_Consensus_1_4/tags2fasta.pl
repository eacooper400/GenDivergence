#!/usr/bin/perl -w
#
# tags2fasta.pl
#
# Convert the catalog.tags file into a fasta file
#
# October 11, 2013

use strict;

# Get the name of the input and output files from the command line
my ($USAGE) = "$0 <input.tsv> <output.fasta>\n";
unless (@ARGV) {
  print $USAGE;
  exit;
}
my ($input, $output) = @ARGV;

# Open both files, then process the input one line at a time
open (IN, $input) || die "\nUnable to open the file $input!\n";
open (OUT, ">$output") || die "\nUnable to open the file $output!\n";

while (<IN>) {
  chomp $_;
  my @info = split(/\s{1,}/, $_);
  print OUT ">", $info[2], "\n";
  print OUT $info[8], "\n";
}
close(IN);
close(OUT);
exit;

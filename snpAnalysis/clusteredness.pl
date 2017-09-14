#!/usr/bin/perl
#
# Clusteredness.pl
#
# A script to estimate the average "clusteredness" of individuals
# from STRUCTURE output
#
# Written by Liz Cooper

use warnings;
use strict;

my($USAGE)= "$0 <Input_Filename>\n\tInput_Filename = The output file generated by STRUCTURE\n";

# Collect the name of the input file at the command line
unless (@ARGV) {
  print $USAGE, "\n";
  exit;
}
my($inputfile) = $ARGV[0];
open (INPUT, $inputfile) || die "Unable to open the file $inputfile!\n";

my $G = 0;
my $I = 0;

# Read in the STRUCTURE input file;
# Skip all lines until getting to the Q-matrix
# Then, calculate the avg. membership for each individual
my $flag = 0;

while (<INPUT>) {
  chomp $_;
  if ($_ =~ /^Inferred\sancestry/) {
    $flag++;
  } elsif ($_ =~ /^\s*$/) {
    $flag=0;
    next;
  } elsif ($flag) {
    if ($_ =~ /Label/) {
      next;
    } else {
      my @line = split (/:/, $_);
      $line[1] =~ s/^\s{1,}//;
      my @q = split(/\s/, $line[1]);
      my $sum = 0;
      for (my $i = 0; $i < scalar @q; $i++) {
	my $tmp = ($q[$i] - (1/(scalar @q)))**2;
	$sum += $tmp;
      }
      my $mem = ((scalar @q)/((scalar @q) - 1)) * $sum;
      $mem = $mem**(1/2);
      $G += $mem;
      $I++;
    }
  } else {
    next;
  }
}
close(INPUT);

$G = $G * (1/$I);
print $G, "\n";
exit;

    
  
  
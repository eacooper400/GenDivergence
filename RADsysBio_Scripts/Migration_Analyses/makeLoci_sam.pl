#!/usr/bin/perl -w
#
# makeLoci_sam.pl
#
# Make a file with locus information (instead of SNPs) for individuals
# Use a SAM file to get the locus info
# This should be able to be used with IMa2 or Migrate with minor modifications
#
# October 2, 2013

use strict;
use Data::Dumper;

# Get the sites list file and the consensus fasta file names from the command line
# Also get the name of the output file
my ($USAGE) = "$0 <sites.list> <in.sam> <output.loci>\n";
unless (@ARGV) {
  print $USAGE;
  exit;
}
my ($sitesfile, $samfile, $output) = @ARGV;

# Do an initial read through of the sites list to get all of the 
# tags and the positions associated with them into an array

my %sites = ();
my %genotypes = ();

open (SITES, $sitesfile) || die "\nUnable to open the file $sitesfile!\n";

while (<SITES>) {
  chomp $_;
  my @info = split(/\t/, $_);
  $info[0] =~ s/^JH//g;
  my $id = $info[0] . "." . $info[1];

  if (exists $sites{$info[0]}) {
    push (@{$sites{$info[0]}}, $info[1]);
  } else {
    my @temp = ();
    push (@temp, $info[1]);
    @{$sites{$info[0]}} = @temp;
  }

  my @populations = @info[2..(scalar @info - 1)];
  for (my $p = 0; $p < scalar @populations; $p++) {
    my @new = split('', $populations[$p]);
    my $new_string = join(",", @new);
    $populations[$p] = $new_string;
  }
  @{$genotypes{$id}} = @populations;
}
close(SITES);

# Read through the SAM file, and save the tags with positions
my %tags = ();
my %tag_ids = ();

open (SAM, $samfile) || die "\nUnable to open the file $samfile!\n";

while (<SAM>) {
  chomp $_;
  
  if ($_ =~ /^\@/) {
    next;
  } else {
    my @info = split(/\t/, $_);
    $info[2] =~ s/^JH//g;
    my $t_id = $info[2] . "." . $info[3];
    
    if (exists $sites{$info[2]}) {
      my @positions = @{$sites{$info[2]}};
      foreach my $pos (@positions) {
	if (($pos >= $info[3]) && ($pos <= ($info[3] + 94))) {
	  if (exists $tag_ids{$t_id}) {
	    my $check = 0;
	    foreach my $test (@{$tag_ids{$t_id}}) {
	      my $test2 = $test;
	      $test2 =~ s/^[0-9]{1,}\.//g;
	      if ($test2 == $pos) {
		$check++;
	      }
	    }
	    unless ($check > 0) {
	      push (@{$tag_ids{$t_id}}, "$info[2].$pos");
	    }
	  } else {
	    $tags{$t_id} = $info[9];
	    my @temp = ();
	    push (@temp, "$info[2].$pos");
	    @{$tag_ids{$t_id}} = @temp;
	  }
	}
      }
    } else {
      next;
    }
  }
}
close(SAM);

print Dumper (\%tags);
open (FASTA, ">temp2.fasta") || die "\nUnable to open the file temp.fasta\n";

my @keys = keys %tags;
my @sorted_keys = sort {$a <=> $b} @keys;

foreach my $key (@sorted_keys) {
  print FASTA ">", $key, "\n";
  print FASTA $tags{$key}, "\n";
}
close(FASTA);


# Save the names of the individuals in seperate arrays
my @Lg_For = ('LF3048','LF3171','LF3402','LF3539','LF3574','LF3642','LF3657','LF3658','LF3670','LF3681','LF3687','LF3695','LF3697','LF3738','LF3747','LF3748','LF3751','LF3752','LF3754','LF3755','LF3835','LF3844','LF3894','LF3895','LF3913','LF3922','LF3923','LF3924','LF3959','LF3960','LF0687','LF0367','LF0520');
my @Sm_For = ('SF3162','SF3582','SF3631','SF3633','SF3636','SF3640','SF3652','SF3661','SF3676','SF3683','SF3699','SF3750','SF3753','SF3774','SF3790','SF3914','SF3934','SF3943','SF0241','SF0824','SF0851','SF0855');
my @Fuli = ('FU0261','FU0262','FU0278','FU0286','FU0290','FU0293','FU0294','FU0295','FU0303','FU0306','FU0309','FU0342','FU0343','FU0348','FU0359','FU0393','FU0411','FU0475','FU0506','FU0512');
my @Mag = ('MA3607','MA3626','MA3656','MA3665','MA3666','MA3684','MA3688','MA3690','MA3693','MA3740','MA3746','MA3810');

# Now open the output file for printing
open (OUT, ">$output") || die "\nUnable to open the file $output!\n";

# Start going through the list of positions in the sites array
my @tag_keys = keys %tag_ids;
my @sorted_keys = sort {$a <=> $b} @tag_keys;
print scalar @sorted_keys, "\n";

foreach my $key (@sorted_keys) {
  
  # Print out the locus name before printing the individuals
  print OUT "Locus ", $key, "\n";

  # Get the list of positions and the list of genotypes for this site
  # Get the consensus sequence for the site
  my @snp_positions = @{$tag_ids{$key}};  
  my $consensus = $tags{$key};
  my $tag_start = (split/\./, $key)[1];

  # Get a list of the reference bases at every SNP position
  my @ref_bases = ();
  foreach my $snp_pos (@snp_positions) {
    my $spos = (split(/\./, $snp_pos))[1];
    my $tpos = $spos - $tag_start;
    my $ref = substr($consensus, $tpos, 1);
    push (@ref_bases, $ref);
  }

  # Now, go through every individual in each population, and print 2 DNA strings

  # Population 1: Large Fortis
  for (my $i = 0; $i < scalar @Lg_For; $i++) {
    my $string1 = $consensus;
    my $string2 = $consensus;

    for (my $s = 0; $s < scalar @snp_positions; $s++) {
      my $temp_pos = (split(/\./, $snp_positions[$s]))[1];
      my $j = $temp_pos - $tag_start;
      my @genotypes = @{$genotypes{$snp_positions[$s]}};
      my @individuals = split(/,/, $genotypes[0]);
  
      my $new_base = $individuals[$i];
      if ($new_base =~ /[MRWSYK]/) {
	my $base2 = get_snp_bases($new_base, $ref_bases[$s]);
	substr($string1, $j, 1) = $ref_bases[$s];
	substr($string2, $j, 1) = $base2;
      } else {
	substr($string1, $j, 1) = $new_base;
	substr($string2, $j, 1) = $new_base;
      }
    }
    print OUT $Lg_For[$i], "_1", " ", " ", $string1, "\n";
    print OUT $Lg_For[$i], "_2", " ", " ", $string2, "\n";
  }

  # Populations 2: Small Fortis
  for (my $i = 0; $i < scalar @Sm_For; $i++) {
    my $string1 = $consensus;
    my $string2 = $consensus;

    for (my $s = 0; $s < scalar @snp_positions; $s++) {
      my $temp_pos = (split(/\./, $snp_positions[$s]))[1];
      my $j = $temp_pos - $tag_start;
      my @genotypes = @{$genotypes{$snp_positions[$s]}};
      my @individuals = split(/,/, $genotypes[1]);
  
      my $new_base = $individuals[$i];
      if ($new_base =~ /[MRWSYK]/) {
	my $base2 = get_snp_bases($new_base, $ref_bases[$s]);
	substr($string1, $j, 1) = $ref_bases[$s];
	substr($string2, $j, 1) = $base2;
      } else {
	substr($string1, $j, 1) = $new_base;
	substr($string2, $j, 1) = $new_base;
      }
    }
    print OUT $Sm_For[$i], "_1", " ", " ", $string1, "\n";
    print OUT $Sm_For[$i], "_2", " ", " ", $string2, "\n";
  }

  # Population 3: Fuliginosa
  for (my $i = 0; $i < scalar @Fuli; $i++) {
    my $string1 = $consensus;
    my $string2 = $consensus;

    for (my $s = 0; $s < scalar @snp_positions; $s++) {
      my $temp_pos = (split(/\./, $snp_positions[$s]))[1];
      
      my @genotypes = @{$genotypes{$snp_positions[$s]}};
      my @individuals = split(/,/, $genotypes[2]);
      my $j = $temp_pos - $tag_start;
      my $new_base = $individuals[$i];
      if ($new_base =~ /[MRWSYK]/) {
	my $base2 = get_snp_bases($new_base, $ref_bases[$s]);
	substr($string1, $j, 1) = $ref_bases[$s];
	substr($string2, $j, 1) = $base2;
      } else {
	substr($string1, $j, 1) = $new_base;
	substr($string2, $j, 1) = $new_base;
      }
    }
    print OUT $Fuli[$i], "_1", " ", " ", $string1, "\n";
    print OUT $Fuli[$i], "_2", " ", " ", $string2, "\n";
  }

  # Population 4: Magnirostris
  for (my $i = 0; $i < scalar @Mag; $i++) {
    my $string1 = $consensus;
    my $string2 = $consensus;

    for (my $s = 0; $s < scalar @snp_positions; $s++) {
      my $temp_pos = (split(/\./, $snp_positions[$s]))[1];
      my $j = $temp_pos - $tag_start;
      my @genotypes = @{$genotypes{$snp_positions[$s]}};
      my @individuals = split(/,/, $genotypes[3]);
  
      my $new_base = $individuals[$i];
      if ($new_base =~ /[MRWSYK]/) {
	my $base2 = get_snp_bases($new_base, $ref_bases[$s]);
	unless ($base2) {
	  print $j, "\t", $consensus, "\n";
	}
	substr($string1, $j, 1) = $ref_bases[$s];
	substr($string2, $j, 1) = $base2;
      } else {
	substr($string1, $j, 1) = $new_base;
	substr($string2, $j, 1) = $new_base;
      }
    }
    print OUT $Mag[$i], "_1", " ", " ", $string1, "\n";
    print OUT $Mag[$i], "_2", " ", " ", $string2, "\n";
  }
}
  
close(OUT);
exit;

##########################################################################
# Subroutine(s)
##########################################################################
sub get_snp_bases {
  my ($het, $ref) = @_;
  my $new = '';

  if ($ref =~ /A/) {
    if ($het =~ /M/) {
      $new = 'C';
    } elsif ($het =~ /R/) {
      $new = 'G';
    } elsif ($het =~ /W/) {
      $new = 'T';
    } else {
      print "ERROR: HET CODE IS: $het and REF BASE IS: $ref!\n";
    }
  } elsif ($ref =~ /C/) {
    if ($het =~ /M/) {
      $new = 'A';
    } elsif ($het =~ /S/) {
      $new = 'G';
    } elsif ($het =~ /Y/) {
      $new = 'T';
    } else {
      print "ERROR: HET CODE IS: $het and REF BASE IS: $ref!\n";
    }
  } elsif ($ref =~ /G/) {
    if ($het =~ /R/) {
      $new = 'A';
    } elsif ($het =~ /S/) {
      $new = 'C';
    } elsif ($het =~ /K/) {
      $new = 'T';
    } else {
      print "ERROR: HET CODE IS: $het and REF BASE IS: $ref!\n";
    }
  } elsif ($ref =~ /T/) {
    if ($het =~ /W/) {
      $new = 'A';
    } elsif ($het =~ /Y/) {
      $new = 'C';
    } elsif ($het =~ /K/) {
      $new = 'G';
    } else {
      print "ERROR: HET CODE IS: $het and REF BASE IS: $ref!\n";
    }
  }

  return($new);
}
  

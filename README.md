# GenDivergence
Pipeline Instructions, Protocols, and Scripts used in ![Genomic evidence for convergent evolution of a key trait underlying divergence in island birds](http://onlinelibrary.wiley.com/doi/10.1111/mec.14116/abstract).
Please cite: Cooper, EA and J.A.C. Uy. (2017) *Molecular Ecology***26**(14):3760-3774.

## Contents

### 1.  dRAD_pipeline:
The set of scripts, along with detailed instructions, for running the bioinformatics pipeline described in the paper.  This pipeline uses a combination of the ![Stacks](http://catchenlab.life.illinois.edu/stacks/) package, ![BWA](http://bio-bwa.sourceforge.net/bwa.shtml),![Samtools](http://samtools.sourceforge.net/), and custom Perl scripts to *de novo* assemble a multiplex dRAD-seq library and call SNPs.

### 2.  snpAnalysis:
The complete set of scripts used for all downstream analyses in the paper.  Includes details on command line arguments for each script as well as an example workflow to perform the analyses in the order they were done in the paper.

### 3.  labProtocols:
A set of pdf and LaTex documents with molecular lab protocols relevant to generating the multiplexed dRAD-seq Illumina library.  Also includes primer and adapter sequences.

### 4.  dadiScripts:
The python scripts used to run all 6 migration models described in the paper with the program ![dadi](https://popgensealab.wordpress.com/dadi-inference/).

### 5.  Monarcha_nexus_files.tar.gz
A gzipped archive of the nexus format sequence files used to generate the SNAPP phylogeny.

#! /usr/bin/env perl
use strict;
use warnings;

my $indir="clusters";
my $mafft="/home/share/users/wangkun2010/software/mafft/mafft-linux64/mafft.bat";

my @fasta=<$indir/*.fa>;

open O,"> $0.sh";
foreach my $fasta(@fasta){
    print O "$mafft $fasta > $fasta.aln\n";
}
close O;

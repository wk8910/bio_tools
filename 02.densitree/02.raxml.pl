#! /usr/bin/env perl
use strict;
use warnings;

my $indir="fasta";
my $now=$ENV{'PWD'};

my @dir=<$indir/*>;

open O,"> $0.sh";
foreach my $dir(@dir){
    if(-d "$dir"){
        print O "cd $now/$dir; /home/tibet_loach/bio/clustalw2/clustalw-2.1-linux-x86_64-libcppstatic/clustalw2 -INFILE=align.fa -CONVERT -OUTFILE=align.phy -OUTPUT=PHYLIP; /home/tibet_loach/bio/raxml/standard-RAxML/raxmlHPC -s align.phy -n align.phb -f a -m GTRGAMMAI -k -x 271828 -N 100 -p 31415 -o ZF; cd $now\n";
    }
}
close O;

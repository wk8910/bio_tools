#! /usr/bin/env perl
use strict;
use warnings;

my $sta="/home/pool_3/users/wangkun2010/deepsea/03.synteny/03.extract_sequence/sta.pl.txt"; # sta file generated with ../13.maf_gene_tree/gene_sta.pl
my $outdir="genes";
my $out_name="cds.paml";

my $now=$ENV{'PWD'};
my $tool1="$now/scripts/filter_stop_codon.pl";
my $tool2="$now/scripts/Gblocks2Paml.pl";

`mkdir $outdir` if(!-e $outdir);

open O,"> $0.sh";
open I,"< $sta";
<I>;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($fa,$percent)=@a;
    next unless($percent>=0.5);
    $fa=~/genes\/(.*).fa$/;
    my $id=$1;
    print O "cd $outdir; mkdir $id; cd $id; perl $tool1 /home/pool_3/users/wangkun2010/deepsea/03.synteny/03.extract_sequence/$fa cds; perl $tool2 cds.fa $out_name; cd $now\n";
}
close I;
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my @query=<query/*.pep>;
my $outdir="/data2/home/wangkun/03.sterlet/02.protein_align/01.align/alignment/sterlet";
my $ref="/data2/home/wangkun/03.sterlet/00.genome/sterlet.fa";
my $now=$ENV{'PWD'};

open O,"> $0.sh";
foreach my $query(@query){
    $query=~/(\w+)\.pep$/;
    my $id=$1;
    print O "cd $outdir; ~/software/blat/blat $ref $now/$query -ooc=$ref.ooc -t=dnax -q=prot $id.psl; cd -\n";
}
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $file="bison_cattle.lst.gz";
my $outdir="chr";
`mkdir $outdir` if(!-e $outdir);

open I,"zcat $file |";
my $head=<I>;
my $chr_pre="NA";
while (<I>) {
    /^(\S+)/;
    my $chr=$1;
    if($chr ne $chr_pre){
        close O;
        open O,"| gzip - > $outdir/$chr.lst.gz";
        print O "$head";
    }
    print O "$_";
    $chr_pre=$chr;
}
close I;
close O;

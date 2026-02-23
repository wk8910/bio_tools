#! /usr/bin/env perl
use strict;
use warnings;

my $vcf="pda_e.phase.vcf.gz";
my $outdir="vcf";
`mkdir $outdir` if(!-e $outdir);

open I,"zcat $vcf |";
my $prefix;
while(<I>){
    if(/^##/){
        $prefix.=$_;
        next;
    }
    if(/^#/){
        $prefix.=$_;
        last;
    }
}

my $chr_pre="NA";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my $chr=$a[0];
    next if($chr=~/scaffold/);
    if($chr ne $chr_pre){
        close O;
        open O,"| gzip - > $outdir/$chr.vcf.gz";
        print O "$prefix";
    }
    print O "$_\n";
    $chr_pre=$chr;
}
close O;
close I;

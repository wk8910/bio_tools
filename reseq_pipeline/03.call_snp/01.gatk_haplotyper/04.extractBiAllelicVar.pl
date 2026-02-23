#! /usr/bin/env perl
use strict;
use warnings;

my $vcf="gatk_snp.vcf.gz";
open(O,"| gzip - > $0.vcf.gz");
open(I,"zcat $vcf |");
while(<I>){
    if(/^#/){
	print O "$_";
	next;
    }
    my @a=split(/\s+/);
    next unless($a[4]=~/^[ATCG]+$/);
    print O "$_";
}
close I;
close O;

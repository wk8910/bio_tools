#! /usr/bin/env perl
use strict;
use warnings;

my $bgzip="bgzip";
my $in_dir="vcf_step3";
my $out="$0.vcf.gz";

my @vcf=<$in_dir/*.vcf.gz>;
my $control=0;
open O,"| $bgzip -c > $out";
foreach my $vcf(@vcf){
    $control++;
    open I,"zcat $vcf |";
    while(<I>){
        if(/^#/){
            if($control==1){
	print O "$_";
            }
        }
        else{
            print O "$_";
        }
    }
    close I;
}
close O;


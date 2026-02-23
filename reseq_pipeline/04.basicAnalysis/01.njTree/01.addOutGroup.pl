#! /usr/bin/env perl
# add the last individual with 0/0 as outgroup
use strict;
use warnings;

my $vcf="../snp.vcf.gz";
my $out="snp_out.vcf.gz";

open I,"zcat $vcf |";
open O,"| bgzip -c > $out";
while(<I>){
    chomp;
    if(/^##/){
        print O "$_\n";
        next;
    }
    elsif(/^#/){
        my @a=split(/\s+/);
        push @a,"ptr";
        print O join "\t",@a,"\n";
    }
    else{
        my @a=split(/\s+/);
        push @a,"0\/0";
        print O join "\t",@a,"\n";
    }
}
close O;
close I;

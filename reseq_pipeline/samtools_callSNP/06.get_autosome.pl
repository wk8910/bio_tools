#! /usr/bin/env perl
use strict;
use warnings;

my $input="05.filter_repeat.pl.vcf.gz";
my $output="$0.vcf.gz";
my $bgzip="bgzip";

open O,"| $bgzip -c > $output";
open I,"zcat $input |";
while(<I>){
    if(/^#/){
        print O "$_";
    }
    else{
        next if(/^chrY/ || /^chrX/);
        print O "$_";
    }
}
close I;
close O;

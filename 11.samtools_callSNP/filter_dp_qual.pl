#! /usr/bin/env perl
use strict;
use warnings;

my $vcf=shift;
my $out=shift;
my $min_dp=2; # min dp for each sample
my $max_dp=50; # max dp for each sample
my $min_qual=30; # min qual for each site

open O,"| gzip - > $out";
open I,"zcat $vcf |";
my $num;
my $min_dp_every_site=0;
my $max_dp_every_site=0;
while (<I>) {
    chomp;
    if(/^##/){
        print O "$_\n";
    }
    elsif(/^#/){
        print O "$_\n";
        my @head=split(/\s+/);
        my $num=@head-9;
        $min_dp_every_site=$num*$min_dp;
        $max_dp_every_site=$num*$max_dp;
    }
    else{
        my @a=split(/\s+/);
        my ($chr,$pos,$id,$ref,$alt,$qual)=@a;
        next unless(length($alt)==1);
        $a[7]=~/DP=(\d+)/;
        my $dp=$1;
        next unless($dp >= $min_dp_every_site && $dp <= $max_dp_every_site);
        next unless($qual >= $min_qual);
        print O "$_\n";
    }
}
close I;
close O;

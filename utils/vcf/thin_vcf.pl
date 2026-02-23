#! /usr/bin/env perl
use strict;
use warnings;

my ($input,$ratio)=@ARGV;
die "Usage: <intput vcf> <thin ratio>\nthin ratio should from 0~1\n" if(@ARGV<2);

if($input=~/\.gz$/){
    open I,"zcat $input |";
}
else {
    open I,"< $input";
}
$input=~/([^\/]+)\.vcf/;
my $filename=$1;
open O,"| gzip - > $filename.thin$ratio.vcf.gz";
while (<I>) {
    chomp;
    if(/^#/){
        print O "$_\n";
    }
    else {
        my $x=rand(1);
        if($x<$ratio){
            print O "$_\n";
        }
    }
}
close O;
close I;

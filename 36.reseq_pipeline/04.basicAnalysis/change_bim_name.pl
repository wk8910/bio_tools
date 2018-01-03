#! /usr/bin/env perl
use strict;
use warnings;

my $temp="plink.bim.bimbak";
if(-e $temp){
    exit("This don't need to be run!\n");
}
else{
    `cp plink.bim $temp`;
}

open(I,"< $temp");
open(O,"> plink.bim");
my $control=0;
my $pre="impossible";
my $last_pos=0;
while(<I>){
    my @a=split(/\s+/);
    my $chr=$a[0];
    my $pos=$a[3];
    if($chr ne $pre){
	$control=10000+$last_pos;
    }
    $a[0]=1;
    $a[3]=$control+$pos;
    $last_pos=$a[3];
    $pre=$chr;
    print O join "\t",@a,"\n";
}
close O;
close I;

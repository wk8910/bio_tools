#! /usr/bin/env perl
use strict;
use warnings;

my $in="Dadi_data";
my $outdir="01.split_data";
my $size=100000;

`mkdir $outdir` if(!-e $outdir);

open I,"< $in" or die "Cannot open $in\n";
my $head=<I>;
chomp $head;
my $control=0;
my $num=0;
while(<I>){
    chomp;
    $control=($control>=$size)?0:$control;
    if($control==0){
        close O;
        open O,"> $outdir/$num.data" or die "Cannot create $outdir/$num.data\n";
        print O "$head\n";
        $num++;
    }
    print O "$_\n";
    $control++;
}
close I;
close O;

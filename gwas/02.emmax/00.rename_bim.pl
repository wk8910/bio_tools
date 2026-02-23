#! /usr/bin/env perl
use strict;
use warnings;

my $in="prune.bim.old";
my $out="prune.bim";

open O,"> $out";
open I,"< $in";
my $chr_pre="";
my $pos_pre="";
my $step=0;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($chr,$pos)=($a[0],$a[3]);
    if(!$chr_pre){
	$chr_pre=$chr;
    }
    if($chr_pre ne $chr){
	$step+=$pos_pre+1000;
    }
    my $new_pos=$pos+$step;
    $a[0]=1;
    $a[3]=$new_pos;
    my $line=join "\t",@a;
    print O "$line\n";
    $chr_pre=$chr;
    $pos_pre=$pos;
}
close I;
close O;

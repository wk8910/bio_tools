#! /usr/bin/env perl
use strict;
use warnings;

# extract roh location from bcftools roh

my $roh_input=shift;
my $output="$roh_input.bed";

my %region;
my $num=0;
open I,"< $roh_input";
<I>;
my $chr_pre="NULL";
while(<I>){
    my @a=split(/\s+/);
    my ($chr,$pos,$state,$quality,$sample)=@a;
    if($chr ne $chr_pre or $state==1){
	$num++;
	$region{$num}{chr}=$chr;
	$region{$num}{min}=$pos;
	$region{$num}{max}=$pos;
	$chr_pre=$chr;
	while(<I>){
	    my @b=split(/\s+/);
	    ($chr,$pos,$state,$quality,$sample)=@b;
	    if($chr ne $chr_pre or $state==0){
		$chr_pre = $chr;
		last;
	    }
	    if($pos < $region{$num}{min}){
		$region{$num}{min} = $pos;
	    }
	    if($pos > $region{$num}{max}){
		$region{$num}{max} = $pos;
	    }
	    $chr_pre = $chr;
	}
    }
}
close I;

open O,"> $output";
foreach my $num(sort {$a<=>$b} keys %region){
    my $chr=$region{$num}{chr};
    my $start = $region{$num}{min};
    my $end = $region{$num}{max};
    print O "$chr\t$start\t$end\n";
}
close O;

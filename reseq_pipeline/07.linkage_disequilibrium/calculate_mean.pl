#! /usr/bin/env perl
use strict;
use warnings;

my $ld=shift;
my $out="$ld.window.sta";
my $window_size=50000;

my %sta;
open I,"zcat $ld |";
<I>;
while(<I>){
    chomp;
    s/^\s*//g;
    my @a=split(/\s+/);
    my ($chr,$pos1,$pos2,$r2)=($a[0],$a[1],$a[4],$a[6]);
    if($chr=~/^\d+$/){
	my $pre=0 x (2-length($chr));
	$chr="Chr".$pre.$chr;
    }
    my $w1=int($pos1/$window_size)*$window_size+int($window_size/2);
    my $w2=int($pos2/$window_size)*$window_size+int($window_size/2);
    next unless($w1 ne $w2);
    $sta{$chr}{$w1}{r2}+=$r2;
    $sta{$chr}{$w1}{n}++;
}
close I;

open O,"> $out";

foreach my $chr(sort keys %sta){
    foreach my $window(sort {$a<=>$b} keys %{$sta{$chr}}){
	my $mean="NA";
	my $r2=$sta{$chr}{$window}{r2};
	my $n=$sta{$chr}{$window}{n};
	$mean=$r2/$n if($n>0);
	print O "$chr\t$window\t$mean\n";
    }
}
close O;

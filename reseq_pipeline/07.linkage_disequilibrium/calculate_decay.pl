#! /usr/bin/env perl
use strict;
use warnings;

my $ld=shift;
my $out="$ld.decay.sta";
my $window_size=1000;

my %sta;
open I,"zcat $ld |";
<I>;
while(<I>){
    chomp;
    s/^\s*//g;
    my @a=split(/\s+/);
    my ($pos1,$pos2,$r2)=($a[1],$a[4],$a[6]);
    my $dis=abs($pos2-$pos1);
    $dis=int($dis/$window_size + 0.5)*$window_size;
    $sta{$dis}{r2}+=$r2;
    $sta{$dis}{n}++;
}
close I;

open O,"> $out";
print O "dis\tmean_r2\n";
foreach my $dis(sort {$a<=>$b} keys %sta){
    my $r2=$sta{$dis}{r2};
    my $n=$sta{$dis}{n};
    my $mean_r2=$r2/$n;
    print O "$dis\t$mean_r2\n";
}
close O;

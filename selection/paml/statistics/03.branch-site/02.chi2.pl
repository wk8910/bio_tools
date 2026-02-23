#! /usr/bin/env perl
use strict;
use warnings;

my $in="All.branchsite.result.out";
my $out="All.branchsite.result.chi2.out";
my $freeratio_result="../01.freeratio/All.freeratio.result.out";
my $chi2="/home/share/users/wangkun2010/software/paml/paml4.9e/src/chi2";

my %pass;
open (F,"$freeratio_result")||die"$!";
while (<F>){
    chomp;
    my @a=split(/\s+/,$_);
    next if /^cluster\s+/;
    $pass{$a[0]}++ if ($a[1]<150 || $a[6]>2);
}
close F;

my %paml;
open (F,"$in")||die"$!";
while (<F>){
    chomp;
    next if /^cluster\s+/;
    my @a=split(/\t/,$_);
    next if exists $pass{$a[0]};
    $paml{$a[0]}{$a[2]}{$a[3]}{lnl}=$a[4];
    $paml{$a[0]}{$a[2]}{$a[3]}{w}=$a[5];
    $paml{$a[0]}{$a[2]}{$a[3]}{BEB}=$a[6];
}
close F;

open (O,">$out");
print O "cluster\tspeices\tlnl_fix\tlnl_nofix\tw_fix\tw_nofix\tP_value\tBEB\n";
for my $k1 (sort keys %paml){
    for my $k2 (sort keys %{$paml{$k1}}){
        my ($lnl1,$lnl2,$w1,$w2)=($paml{$k1}{$k2}{fix}{lnl},$paml{$k1}{$k2}{nofix}{lnl},$paml{$k1}{$k2}{fix}{w},$paml{$k1}{$k2}{nofix}{w});
        my $deltalnl=2*abs($lnl1-$lnl2);
        my $p=`$chi2 1 $deltalnl`;
        $p=~/prob\s*=\s*(\S+)\s+/ or die "$p\n";
        $p=$1;
        print O "$k1\t$k2\t$lnl1\t$lnl2\t$w1\t$w2\t$p\t$paml{$k1}{$k2}{nofix}{BEB}\n";
    }
}
close O;

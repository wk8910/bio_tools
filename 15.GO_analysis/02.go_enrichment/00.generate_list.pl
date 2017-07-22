#! /usr/bin/env perl
use strict;
use warnings;

my $in="All.branch.chi2.fdr.out";

my %hash;
open I,"< $in";
<I>;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($id,$type,$fdr)=($a[0],$a[1],$a[12]);
    next unless($fdr <= 0.05);
    $hash{$type}{$id}=1;
}
close I;

foreach my $type(keys %hash){
    open O,"> $type.lst";
    foreach my $id(sort keys %{$hash{$type}}){
        print O "$id\n";
    }
    close O;
}

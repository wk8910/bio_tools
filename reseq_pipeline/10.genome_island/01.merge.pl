#! /usr/bin/env perl
use strict;
use warnings;

my $pi_1="pda_e.txt";
my $pi_2="pro.txt";
my $fst="fst.txt";

my %fst;
open(I,"< $fst");
<I>;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($chr,$pos,$fst)=($a[1],$a[2],$a[4]);
    $fst{$chr}{$pos}=$fst;
}
close I;

open(O,"> $0.txt");
print O "chr\tpos\tfst\n";
foreach my $chr(sort keys %fst){
    next unless($chr=~/^Chr/);
    foreach my $pos(sort {$a<=>$b} keys %{$fst{$chr}}){
	my $fst=$fst{$chr}{$pos};
	print O "$chr\t$pos\t$fst\n";
    }
}
close O;

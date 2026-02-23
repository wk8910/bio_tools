#! /usr/bin/env perl
use strict;
use warnings;

my %hash;
my %strict;
my $sum=0;
my $strict_sum=0;
open(I,"< LocalTrees.out");
while (<I>) {
    chomp;
    next unless(/^(cactus\d+).*length: (\d+)/);
    my ($tree,$len)=($1,$2);
    $hash{$tree}+=$len;
    $sum+=$len;
    next if($len<1000);
    $strict{$tree}+=$len;
    $strict_sum+=$len;
}
close I;

open O,"> $0.sta";
foreach my $tree(sort {$hash{$b} <=> $hash{$a}} keys %hash){
    my $len=$hash{$tree};
    my $per=$len/$sum;
    print O "$tree\t$len\t$per\n";
}
close O;

open O,"> $0.strict.sta";
foreach my $tree(sort {$strict{$b} <=> $strict{$a}} keys %strict){
    my $len=$strict{$tree};
    my $per=$len/$strict_sum;
    print O "$tree\t$len\t$per\n";
}
close O;

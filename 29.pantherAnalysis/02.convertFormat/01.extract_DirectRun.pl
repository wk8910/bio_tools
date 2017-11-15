#! /usr/bin/env perl
use strict;
use warnings;

my $interproscan="panther.out";
my $out="panther.list";

my %hash;

open I,"< $interproscan";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my $geneID=$a[0];
    my $pantherID=$a[1];
    $hash{$geneID}{$pantherID}++;
    if($pantherID=~/:/){
        $pantherID=~/^(\w+)/;
        $pantherID=$1;
        $hash{$geneID}{$pantherID}++;
    }
}
close I;

open O,"> $out";
foreach my $geneID(keys %hash){
    my @pantherID=sort keys %{$hash{$geneID}};
    if (@pantherID>1) {
        # print STDERR "$geneID\n";
    }
    my @line=($geneID,@pantherID);
    print O join "\t",@line,"\n";
}
close O;

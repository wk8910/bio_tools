#! /usr/bin/env perl
use strict;
use warnings;

my $interproscan="hadal.interproscan.out.tsv";
my $out="panther.list";

my %hash;

open I,"< $interproscan";
while (<I>) {
    chomp;
    next unless(/PANTHER/);
    my @a=split(/\s+/);
    my $geneID=$a[0];
    next unless($a[3] eq "PANTHER");
    my $pantherID=$a[4];
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

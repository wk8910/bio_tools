#! /usr/bin/env perl
use strict;
use warnings;

my $file=shift;
my $out="$file.go";
open I,"zcat $file |";
my %hash;
while (<I>) {
    chomp;
    # gene="ENSBTAG00000040324.2"
    # next unless(/\/protein_id=\"([^"]+)\"/);
    next unless(/gene=\"([^"]+)\"/);
    my $protein_id=$1;
    while(<I>){
        chomp;
        if(/db_xref="(GO:\d+)"/){
            my $go=$1;
            $hash{$protein_id}{$go}++;
        }
        if(/translation/){
            last;
        }
    }
}
close I;

open O,"> $out";
foreach my $protein_id(sort keys %hash){
    my @line=($protein_id);
    foreach my $go(sort keys %{$hash{$protein_id}}){
        push @line,$go;
    }
    my $line=join "\t",@line;
    print O "$line\n";
}
close O;

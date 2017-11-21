#! /usr/bin/env perl
use strict;
use warnings;

my $lst="02.get_valid_gene_id.pl.txt";
my $gff="gff/gac.gff";
my $out="$0.txt";

my %hash;
open I,"< $gff";
while (<I>) {
    chomp;
    next unless(/Parent=(\w+);protein_id=(\w+)/);
    my ($tid,$pid)=($1,$2);
    $hash{$tid}=$pid;
}
close I;

open O,"> $out";
open I,"< $lst";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    if(exists $hash{$a[0]}){
        $a[0]=$hash{$a[0]};
    }
    else{
        die "$a[0]\n";
    }
    print O join "\t",@a,"\n";
}
close I;
close O;

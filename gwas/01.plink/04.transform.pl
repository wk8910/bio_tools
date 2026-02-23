#! /usr/bin/env perl
use strict;
use warnings;

my $fam="prune.fam.old";
my $phenotype="phenotype.txt";
my $out="prune.fam";

my %phenotype;
open I,"< $phenotype";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    $phenotype{$a[0]}=$a[1];
}
close I;

open O,"> $out";
open I,"< $fam";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    $a[0]="JD";
    $a[1]=~/^\w(.*)/;
    my $id=$1;
    my $phe=-9;
    if(exists $phenotype{$id}){
	$phe=$phenotype{$id};
    }
    $a[5]=$phe;
    my $line=join " ",@a;
    print O "$line\n";
}
close I;
close O;

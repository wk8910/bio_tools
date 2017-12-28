#! /usr/bin/env perl
use strict;
use warnings;

my $input="nc_ref.gff.raw";
my $output="nc_ref.gff";

my %gene;
my %length;
open I,"< $input";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($chr,$source,$type,$start,$end,$qual,$strand,$phase,$info)=@a;
    if($type eq "mRNA"){
        $info=~/ID=(\w+);Parent=(\w+)/;
        my ($mRNA,$gene)=($1,$2);
        $gene{$gene}{$mRNA}=1;
    }
    if($type eq "CDS"){
        $info=~/ID=(\w+);Parent=(\w+)/;
        my ($cds,$mRNA)=($1,$2);
        my $len=$end-$start+1;
        $length{$mRNA}+=$len;
    }
}
close I;

my %keep;
foreach my $gene(keys %gene){
    my $longest=0;
    my $selected="NA";
    foreach my $mRNA(keys %{$gene{$gene}}){
        my $len=0;
        if(exists $length{$mRNA}){
            $len=$length{$mRNA};
        }
        if($len > $longest){
            $longest = $len;
            $selected = $mRNA;
        }
    }
    next if($longest==0);
    $keep{$selected}=$longest;
}

open I,"< $input";
open O,"> $output";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($chr,$source,$type,$start,$end,$qual,$strand,$phase,$info)=@a;
    if($type eq "mRNA"){
        $info=~/ID=(\w+);Parent=(\w+)/;
        my ($mRNA,$gene)=($1,$2);
        if(exists $keep{$mRNA}){
            print O "$_\n";
        }
    }
    if($type eq "CDS"){
        $info=~/ID=(\w+);Parent=(\w+)/;
        my ($cds,$mRNA)=($1,$2);
        if(exists $keep{$mRNA}){
            print O "$_\n";
        }
    }
}
close O;
close I;

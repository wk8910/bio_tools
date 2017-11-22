#! /usr/bin/env perl
use strict;
use warnings;

my $dir="hyphy_running";
my $out="$0.txt";

my @input=`find $dir/ -name "*.json"`;

open O,"> $out";
print O "gene\tspecies\tpvalue\tp_corrected\tlow_value\tlow_percent\thigh_value\thigh_percent\n";
foreach my $input(@input){
    chomp $input;
    $input=~/$dir\/([^\/]+)/;
    my $gene_id=$1;
    my @x=`perl scripts/extract_aBSREL.pl $input`;
    foreach my $x(@x){
        chomp $x;
        my @a=split(/\s+/,$x);
        @a=($gene_id,@a);
        print O join "\t",@a,"\n";
    }
}
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $indir="result";
my $out="$0.txt";

my @result=<$indir/*>;
open O,"> $out";
print O "gene_id\tka\tks\tw\tspecies1\tspecies2\n";
foreach my $gene(@result){
    my @kaks=<$gene/*.kaks>;
    my $light=1;
    my $content="";
    my %result;
    foreach my $kaks(@kaks){
        open I,"< $kaks";
        # <I>;
        my $line=<I>;
        if(!$line){
            $light=0;
            next;
        }
        my @a=split(/\s+/,$line);
        my ($id,$ka,$ks,$w)=($a[0],$a[2],$a[3],$a[4]);
        $id=~/(\w+)_(\w+)_(\w+)/;
        my ($gene_id,$species1,$species2)=($1,$2,$3);
        print "$gene_id\t$species1\t$species2\n";
        # next if($species1 eq "ds" && $species2 eq "ss");
        $content.= "$gene_id\t$ka\t$ks\t$w\t$species1\t$species2\n";
        close I;
    }
    if($light==1){
        print O "$content";
    }
}
close O;

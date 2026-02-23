#! /usr/bin/env perl
use strict;
use warnings;

open I,"zcat bovine.sixSpecies.maf.lst.gz |";
my $head=<I>;
chomp $head;
my @head=split(/\s+/,$head);
my %hash;
my $control=0;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my $light=1;
    for(my $i=2;$i<@a;$i++){
        my $id=$head[$i];
        if($a[$i]=~/[a-z]/){
            $light=0;
        }
        else{
            $hash{$id}++;
        }
    }
    if($light==1){
        $hash{all}++;
    }
    # last if($control++>10000);
}
close I;

foreach my $key(sort keys %hash){
    print "$key\t$hash{$key}\n";
}

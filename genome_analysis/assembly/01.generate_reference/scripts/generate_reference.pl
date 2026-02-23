#! /usr/bin/env perl
use strict;
use warnings;

my $list="bison_cattle.lst.gz";
my $dict="cattle.dict";
my $species="bison";
my $out="bison_cattle.fa";

open I,"zcat $list |";
my $head=<I>;
chomp $head;
my @head=split(/\s+/,$head);
my $species_num;
for(my $i=2;$i<@head;$i++){
    if($species eq $head[$i]){
        $species_num=$i;
        last;
    }
}
if(!$species_num){
    die "Could not find $species in $list!\n";
}
my %hash;
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    # last if($a[0] ne "MT");
    next if($a[$species_num] eq "-");
    $hash{$a[0]}{$a[1]}=$a[$species_num];
}
close I;

open I,"< $dict";
open O,"> $out";
while (<I>) {
    chomp;
    next unless(/SN:(\S+)\s+LN:(\d+)/);
    my ($chr,$len)=($1,$2);
    next unless(exists $hash{$chr});
    my @base;
    for(my $i=0;$i<$len;$i++){
        my $base="N";
        if(exists $hash{$chr}{$i}){
            $base=$hash{$chr}{$i};
        }
        push @base,$base;
    }
    my $seq=join "",@base;
    print O ">$chr\n$seq\n";
}
close I;
close O;

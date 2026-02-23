#! /usr/bin/env perl
use strict;
use warnings;

my ($out,$list,$species,$chr,$length)=@ARGV;
die "Usage: $0 <out file> <list file> <species to convert> <chromosome> <length of the chromosome>\n" if(@ARGV!=5);

open I,"zcat $list |" or die "Cannot open $list\n";
open O,"> $out" or die "Cannot create $out!\n";

my @base=("N") x $length;

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
    next if($a[$species_num] eq "-");
    next unless($a[0] eq $chr);
    my $pos=$a[1]-1;
    next if($pos>=$length);
    $base[$pos]=$a[$species_num];
}
close I;

my $seq=join "",@base;
print O ">$chr\n$seq\n";
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $black="black.list";
my $kin="gatk_snp.kin0";

my %black;
open(I,"< $black");
while(<I>){
    chomp;
    /^(\S+)/;
    my $id=$1;
    $black{$id}=1;
}
close I;

my %kin;
open(I,"< $kin");
my $head=<I>;
print "$head";
my $number=0;
my %count;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my $id1=$a[0];
    my $id2=$a[2];
    next if(exists $black{$id1} || exists $black{$id2});
    my $kinship=$a[7];
    next if($kinship <= 0.0442);
    $count{$id1}++;
    $count{$id2}++;
    $kin{$number}{content}="$_";
    $kin{$number}{kinship}=$kinship;
    # print "$_\n";
    $number++;
}
close I;

foreach my $number(sort {$kin{$b}{kinship} <=> $kin{$a}{kinship}} keys %kin){
    print "$kin{$number}{content}\n";
}

print "\n";
foreach my $id(sort {$count{$b} <=> $count{$a}} keys %count){
    print "$id\t$count{$id}\n";
}

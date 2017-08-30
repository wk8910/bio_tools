#! /usr/bin/perl
use strict;
use warnings;

my $file="all.fasta";
$/=">";

my %hash;
open(I,"< $file");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    my $seq=join "",@lines;# the sequence of fasta is $seq
    my @id=split(/\s+/,$id);
    $id=$id[1]."_".$id[2];
    # $id=$id[1]."_".$id[2]."_".$id[0];
    $hash{$id}=$seq;
}
close I;

open O,"> clean.fa";
foreach my $id(sort keys %hash){
    my $seq=$hash{$id};
    print O ">$id\n$seq\n";
}
close O;

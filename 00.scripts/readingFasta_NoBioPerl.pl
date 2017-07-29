#! /usr/bin/perl
# This script is used to reading fasta file without the help of BioPerl
use strict;
use warnings;

my $file=shift;
$/=">";

open(I,"< $file");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    $id=~/^(\S+)/;
    $id=$1;
    my $seq=join "",@lines;# the sequence of fasta is $seq
    print ">$id\n$seq\n";
}
close I;
$/="\n";

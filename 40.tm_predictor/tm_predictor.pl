#! /usr/bin/env perl
use strict;
use warnings;

my $fasta=shift;
my $matrix="tm.matrix";
my %matrix;
open I,"< $matrix";
my $head=<I>;
chomp $head;
my @head=split(/\s+/,$head);
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my $first=$a[0];
    for(my $i=1;$i<@a;$i++){
        my $second=$head[$i];
        my $value=$a[$i];
        my $mer=uc($first.$second);
        $matrix{$mer}=$value;
    }
}
close I;

$/=">";

open(I,"< $fasta");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    $id=~/^(\S+)/;
    $id=$1;
    my $seq=join "",@lines;# the sequence of fasta is $seq
    # print ">$id\n$seq\n";
    my $tm=calculate($seq);
    print "$id\t$tm\n";
}
close I;
$/="\n";

sub calculate{
    my $seq=shift;
    chomp $seq;
    $seq=~s/\*$//;
    my $len=length($seq);
    $seq=uc($seq);
    my @base=split(//,$seq);
    my $tm=0;
    for(my $i=0;$i<$len-1;$i++){
        my $mer=$base[$i].$base[$i+1];
        if(exists $matrix{$mer}){
            $tm+=$matrix{$mer};
        }
    }
    $tm=(((100/$len)*$tm)-9372)/398;
    return($tm);
}

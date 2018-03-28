#! /usr/bin/perl
use strict;
use warnings;

my $file=shift;
my $percent=0.01;
my $out="$file.random.fa";
$/=">";

my %hash;
my $len=0;

open(I,"< $file");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    $id=~/^(\S+)/;
    $id=$1;
    my $seq=join "",@lines;# the sequence of fasta is $seq
    my @base=split(//,$seq);
    $len=length($seq);
    for(my $i=0;$i<$len;$i++){
        $hash{$i}{$id}=$base[$i];
    }
}
close I;
$/="\n";

my %result;
for(my $i=0;$i<$len;$i++){
    my $x=rand(1);
    next unless($x<$percent);
    foreach my $id(keys %{$hash{$i}}){
        $result{$id}.=$hash{$i}{$id};
    }
}

open O,"> $out";
foreach my $id(sort keys %result){
    print O ">$id\n$result{$id}\n";
}
close O;

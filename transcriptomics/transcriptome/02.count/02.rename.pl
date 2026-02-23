#! /usr/bin/env perl
use strict;
use warnings;

my $out="$0.txt";
my $in="01.combine.pl.txt";
my $tissue="tissue.lst";
my %hash;
open I,"< $tissue";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    $hash{$a[0]}=$a[1];
}
close I;

open O,"> $0.txt";
open I,"< $in";
my $head=<I>;
chomp $head;
my @head=split(/\s+/,$head);
my @b;
foreach my $x(@head){
    $x=~/(\w+)\.(.*)/;
    my ($species,$tissue)=($1,$2);
    my $new=$hash{$tissue};
    $new=~s/\s//g;
    my $ele=$species.".".$new;
    push @b,$ele;
}
print O join "\t",@b,"\n";
while(<I>){
    chomp;
    print O "$_\n";
}
close I;
close O;

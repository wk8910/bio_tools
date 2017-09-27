#! /usr/bin/env perl
use strict;
use warnings;

my $indir="count";
my $out="$0.txt";

my @count=<$indir/*.count>;

my %count;
my @sample;
foreach my $count(@count){
    open I,"< $count";
    $count=~/\/([^\.\/]+)[\/]*/;
    my $sample=$1;
    push @sample,$sample;
    while (<I>) {
        chomp;
        my @a=split(/\s+/);
        my ($id,$num)=@a;
        $count{$id}{$sample}=$num;
    }
    close I;
}

open O,"> $out";
print O join "\t",@sample,"\n";
foreach my $id(sort keys %count){
    my @line=($id);
    foreach my $sample(@sample){
        my $num=0;
        if(exists $count{$id}{$sample}){
            $num=$count{$id}{$sample};
        }
        push @line,$num;
    }
    print O join "\t",@line,"\n";
}
close O;

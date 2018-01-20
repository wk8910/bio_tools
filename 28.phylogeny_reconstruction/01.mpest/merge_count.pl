#! /usr/bin/env perl
use strict;
use warnings;

my @count=@ARGV;
my $out="$0.out";

my %hash;
my %sum;
foreach my $count(@count){
    open I,"< $count";
    while (<I>) {
        chomp;
        my @a=split(/\s+/);
        $hash{$a[0]}{$count}{num}=$a[1];
        # print "$hash{$a[0]}{$count}{num}\n";
        $hash{$a[0]}{$count}{percent}=$a[2];
        $sum{$a[0]}+=$a[2];
    }
    close I;
}

open O,"> $out";
my @head=("tree");
foreach my $count(@count){
    push @head,"$count.num";
    push @head,"$count.percent";
}
print O join "\t",@head,"\n";
foreach my $tree(sort {$sum{$b}<=>$sum{$a}} keys %sum){
    my @line=($tree);
    foreach my $count(@count){
        my ($num,$percent)=(0,0);
        if(exists $hash{$tree}{$count}{num}){
            $num=$hash{$tree}{$count}{num};
            $percent=$hash{$tree}{$count}{percent};
        }
        push @line,($num,$percent);
    }
    print O join "\t",@line,"\n";
}
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $fs="dadi.fs";
my $len="effective.len";
open O,"> model_jointMAFpop1_0.obs" or die "$!\n";

open I,"< $len" or die "$!\n";
my $length=<I>;
chomp $length;
if($length!~/^[\d\.]+$/){
    die "effective length should be specified!\n";
}
close I;

open I,"< $fs" or die "$!\n";

my $head=<I>;
chomp $head;
my @head=split(/\s+/,$head);

my $content=<I>;
chomp $content;
my @content=split(/\s+/,$content);

my $col_num=$head[1];
my $j=0;

my %hash;
my $row_num=0;
my $sum=0;
for(my $i=0;$i<@content;$i++){
    if($j>=$col_num){
        $row_num++;
        $j=0;
    }
    if($i>0){
        $sum+=$content[$i];
    }
    # print "$row_num\t$j\t$content[$i]\n";
    $hash{$j}{$row_num}=$content[$i];
    $j++;
}
close I;
$hash{0}{0}=$length-$sum;

print O "1 observations\n";
my @new_head=("");
for(my $i=0;$i<$head[0];$i++){
    my $str="d0_".$i;
    push @new_head,$str;
}
print O join "\t",@new_head,"\n";
foreach my $j(sort {$a<=>$b} keys %hash){
    my @line;
    my $str="d1_".$j;
    push @line,$str;
    foreach my $row_num(sort {$a<=>$b} keys %{$hash{$j}}){
        my $num=$hash{$j}{$row_num};
        push @line,$num;
    }
    print O join "\t",@line,"\n";
}
close O;

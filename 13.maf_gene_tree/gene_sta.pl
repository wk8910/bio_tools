#! /usr/bin/perl
# 统计有多少基因是完整的
use strict;
use warnings;

my $dir="genes";
my @fa=<$dir/*.fa>;
my $out="$0.txt";
$/=">";

open O,"> $out";
print O "file\tpercent\n";
foreach my $fa(@fa){
    my %hash;
    open(I,"< $fa");
    while (<I>) {
        chomp;
        my @lines=split("\n",$_);
        next if(@lines==0);
        my $id=shift @lines;# the name of fasta is $id
        my $seq=join "",@lines;# the sequence of fasta is $seq
        my @base=split //,$seq;
        for(my $i=0;$i<@base;$i++){
            $hash{$i}{num}++;
            if($base[$i]=~/[ATCGatcg]/){
	$hash{$i}{info}++;
            }
        }
    }
    my $all=0;
    my $info=0;
    foreach my $i(keys %hash){
        $all++;
        next unless(exists $hash{$i}{info});
        if($hash{$i}{info} eq $hash{$i}{num}){
            $info++;
        }
    }
    my $percent=$info/$all;
    print O "$fa\t$percent\n";
    close I;
}
close O;

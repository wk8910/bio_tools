#! /usr/bin/env perl
use strict;
use warnings;

my $bam=shift;
my $out_prefix=shift;

my $dict="/home/share/user/user101/projects/yangshu/11.ref/ptr.dict";
my %hash;
open(I,"< $dict");
while(<I>){
    chomp;
    next unless(/SN:(\S+)\s+LN:(\d+)/);
    my ($chr,$len)=($1,$2);
    $hash{"0"}+=$len;
}
close I;

open(I,"/home/share/user/user101/bin/samtools depth $bam |");
my $control=0;
while(<I>){
    chomp;
    my ($chr,$pos,$depth)=split(/\s+/);
    $hash{$depth}++;
    $hash{"0"}--;
    # last if($control++>10000);
}
close I;

open(O,"> $out_prefix.depth");
my ($totalLength,$cover,$percent,$totalNum,$meanDepth)=(0,0,0,0,0);
foreach my $depth(sort {$a<=>$b} keys %hash){
    print O "$depth\t$hash{$depth}\n";
    $totalLength+=$hash{$depth};
    $totalNum+=$hash{$depth}*$depth;
    if($depth>0){
	$cover+=$hash{$depth};
    }
}
close O;

print STDERR "$totalLength\t$cover\t$totalNum\n";

open(O,"> $out_prefix.sta");
print O "# SampleName\tPercentCovered\tMeanDepth\n";
$percent=$cover/$totalLength;
$meanDepth=$totalNum/$totalLength;
$bam=~/([^\/]+)\.bam$/;
my $name=$1;
print O "$name\t$percent\t$meanDepth\n";
close O;

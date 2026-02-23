#! /usr/bin/env perl
use strict;
use warnings;

my ($bam,$gff,$out)=@ARGV;
# ($bam,$gff)=("bam/brain_1.bam","lungfish.gff");
# $out="$bam.count";

my $window_size=100;
my %gff;
my %len;
open I,"< $gff";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($chr,$source,$type,$start,$end,$score,$strand,$phase,$info)=@a;
    $info=~/ID=([^\;]+);/;
    my $geneid=$1;
    if($end<$start){
        my $tmp=$end;
        $end=$start;
        $start=$tmp;
    }
    my $len=$end-$start+1;
    $len{$geneid}+=$len;
    my $left=int($start/$window_size)*$window_size;
    my $right=int($end/$window_size)*$window_size;
    for(my $i=$left;$i<=$right;$i+=$window_size){
        my $tag=$chr." ".$i;
        $gff{$tag}{$geneid}{start}=$start;
        $gff{$tag}{$geneid}{end}=$end;
    }
}
close I;

print STDERR "$gff loaded...\n";

my %count;
open I,"/home/wangku/software/samtools/build/bin/samtools view $bam |";
my $control=0;
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($qname,$flag,$chr,$pos,$mapq,$cigar,$mname,$mpos,$tlen,$seq,$qual)=@a;
    next if($flag & 4); # next if reads is unmapped
    # print "$cigar $pos\n";
    my $currentPos=$pos;
    while($cigar=~/(\d+)([A-Z])/g){
        my $child_len=$1;
        my $child_type=$2;
        my $start=$currentPos;
        # print "\t$child_len $child_type";
        my $light=0;
        if($child_type=~/[MND]/){
            $currentPos+=$child_len-1;
        }
        if($child_type=~/M/){
            my $end=$currentPos;
            last if($light==1);
            my $left=int($start/$window_size)*$window_size;
            my $right=int($end/$window_size)*$window_size;
            for(my $i=$left;$i<=$right;$i+=$window_size){
	my $tag=$chr." ".$i;
	next if(!exists $gff{$tag});
	foreach my $geneid (sort keys %{$gff{$tag}}){
	    my $s=$gff{$tag}{$geneid}{start};
	    my $e=$gff{$tag}{$geneid}{end};
	    if($s <= $end && $start <= $e){
	        $count{$geneid}++;
	        $light=1;
	        last;
	    }
	}
	last if($light==1);
            }
        }
    }
    # last if($control++>100000);
}
close I;

print STDERR "$bam loaded...\n";

open O,"> $out";
foreach my $geneid(sort keys %count){
    my $count=$count{$geneid};
    my $len=$len{$geneid};
    print O "$geneid\t$len\t$count\n";
}
close O;

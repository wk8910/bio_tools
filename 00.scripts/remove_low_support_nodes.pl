#! /usr/bin/env perl
use strict;
use warnings;

my $tre=shift;
my $cutoff=shift;
my %black_lst;

open I,"< $tre";
while(<I>){
    chomp;
    my $line=$_;
    my @char=split(//,$line);
    while($line=~/\[(\d+)\]/g){
	my $pos=pos($line);
	my $bs=$1;
	if($bs<$cutoff){
	    # print "$pos\t$bs\n";
	    my $clade;
	    my $light=0;
	    my $count=0;
	    for(my $i=$pos-1;$i>=0;$i--){
		$clade.=$char[$i];
		if($char[$i] eq ")"){
		    $light++;
		    $count++;
		}
		if($char[$i] eq "("){
		    $light--;
		    $count++;
		}
		if($count>0 && $light==0){
		    last;
		}
	    }
	    $clade=reverse($clade);
	    &extract($clade);
	    # print "$clade\n";
	}
    }
    last;
}
close I;

foreach my $node(sort keys %black_lst){
    print "$node\n";
}

sub extract{
    my $clade=shift;
    $clade=~s/:[\d\.]+/ /g;
    $clade=~s/\[\d+\]/ /g;
    $clade=~s/[\(\),]/ /g;
    $clade=~s/\s+/ /g;
    $clade=~s/^\s*//;
    $clade=~s/\s*$//;
    my @node=split(/\s+/,$clade);
    foreach my $node(@node){
	$black_lst{$node}++;
    }
}

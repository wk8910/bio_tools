#! /usr/bin/env perl
use strict;
use warnings;

my $input="rst";
my $outtre="$0.tre";
my $outseq="$0.fa";

open I,"< $input";
open O,"> $outseq";
my $tree;
while(<I>){
    chomp;
    if(/tree with node labels for Rod Page's TreeView/){
	$tree=<I>;
	chomp $tree;
	$tree=~s/\d+_//g;
	$tree=~s/\s//g;
    }
    if(/List of extant and reconstructed sequences/){
	<I>;
	<I>;
	<I>;
	while(<I>){
	    chomp;
	    last if(/^\s*$/);
	    s/node #//;
	    /^(\S+)(.*)/;
	    my ($id,$seq)=($1,$2);
	    $seq=~s/\s//g;
	    print O ">$id\n$seq\n";
	    # print O "$_\n";
	}
    }
}
close I;
close O;

open O,"> $outtre";
print O "$tree\n";
close O;

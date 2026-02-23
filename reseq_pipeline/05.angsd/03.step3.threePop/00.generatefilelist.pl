#! /usr/bin/env perl
use strict;
use warnings;

my $keep_list="keep.txt";
my $dir="/home/share/user/user101/projects/yangshu/12.alignment/03.realnBam/";

my %keep;
open(I,"< $keep_list");
while(<I>){
    chomp;
    /^(\S+)\s+(\S+)/;
    my $id=$1;
    my $pop=$2;
    $keep{$pop}{$id}=1;
}
close I;

foreach my $pop(keys %keep){
    open O,"> $pop.lst";
    foreach my $id(sort keys %{$keep{$pop}}){
	my $file="${dir}$id.bam";
	if(-e $file){
	    print O "$file\n";
	}
	else{
	    print STDERR "$file?\n";
	}
    }
    close O;
}

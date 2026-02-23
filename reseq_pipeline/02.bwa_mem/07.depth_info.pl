#! /usr/bin/env perl
use strict;
use warnings;

my @depth=<10.align_sta/*.depth>;

my %depth;

my @id;
foreach my $depth(@depth){
    open I,"< $depth";
    $depth=~/([^\/]+)\.depth/;
    my $id=$1;
    if($id=~/pda01/){
	$id=~s/pda01/pro16/;
    }
    push @id,$id;
    while(<I>){
	chomp;
	my @a=split(/\s+/);
	my ($depth,$count)=@a;
	$depth{$depth}{$id}=$count;
    }
    close I;
}

open O,"> $0.txt";
print O "depth\tid\tpop\tcount\n";
foreach my $depth(sort {$a<=>$b} keys %depth){
    foreach my $id(@id){
	my $pop=$id;
	$pop=~s/\d+.*//g;
	my $count=0;
	if(exists $depth{$depth}{$id}){
	    $count = $depth{$depth}{$id};
	    print O "$depth\t$id\t$pop\t$count\n";
	}
    }
}
close O;

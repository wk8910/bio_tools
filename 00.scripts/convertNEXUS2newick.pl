#! /usr/bin/env perl
use strict;
use warnings;

# Designed for mp-est

my $tree = shift;
my $out = "$tree.nwk";

open I,"< $tree";
my %translate;
my %tree;
my $control=0;
while(<I>){
    chomp;
    next unless(/^\s*translate/);
    while(<I>){
	chomp;
	if(/^\s*(\d+)\s+(\S+)[,;]\s*$/){
	    my ($id,$name)=($1,$2);
	    $translate{$id}=$name;
	    # print "$id\t$name\n";
	}
	elsif(/tree\s*mpest\s*\[([-\d\.]+)\]\s*=\s*(\S+)/){
	    my ($ll,$tree)=($1,$2);
	    # print "$ll\t$tree\n";
	    $control++;
	    $tree{$control}{ll}=$ll;
	    $tree{$control}{tree}=$tree;
	}
    }
}
close I;

open O,"> $out" or die "Canot create $out!\n";
foreach my $control(sort {$tree{$b}{ll} <=> $tree{$a}{ll}} keys %tree){
    my $ll = $tree{$control}{ll};
    my $tree=$tree{$control}{tree};
    # print "$ll\t$tree\n";
    my @names;
    my @positions=(1);
    while($tree=~/(\d+):/g){
	my $pos=pos($tree);

	my $id = $1;
	my $name=$translate{$id};

	push @names,$name;

	my $len=length($id);
	my $start=$pos-$len -1;
	my $end=$pos-1 +1;
	push @positions,($start,$end);
	# print "$start, $end\n";
    }
    my $total_len = length($tree);
    push @positions,$total_len;
    push @names,"";
    my @strings;
    for(my $i=0;$i<@positions;$i=$i+2){
	my $start = $positions[$i];
	my $end = $positions[$i+1];
	my $len=$end-$start+1;
	my $string = substr($tree,$start-1,$len);
	push @strings,$string;
	my $name=shift @names;
	push @strings,$name;
    }
    print O join "",@strings,"\n";
    last;
}
close O;

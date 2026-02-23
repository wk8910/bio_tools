#! /usr/bin/env perl
use strict;
use warnings;

my $obo="go-basic.obo";
my $out="Leaf2Root.txt";

my %result;
open I,"< $obo";
while(<I>){
    chomp;
    if(/^\[Term\]/){
        # print "$_\n";
        my $id;
        my %is_a;
        while(<I>){
            chomp;
            if(/^id:\s+(GO:\d+)/){
	$id=$1;
            }
            if(/is_a:\s+(GO:\d+)/){
	my $go=$1;
	$is_a{$go}++;
            }
            last if(/^\s*$/);
        }
        foreach my $go(keys %is_a){
            $result{$id}{$go}++;
        }
    }
}
close I;

open O,"> $out";
foreach my $id(sort keys %result){
    my %go=&get_parent($id);
    my @go=sort keys %go;
    my $line=join ";",@go;
    print O "$id\t$line\n";
}
close O;

sub get_parent{
    my $sub_id=shift;
    my %sub_go=@_;
    if(exists $result{$sub_id}){
        foreach my $p_id(keys %{$result{$sub_id}}){
            $sub_go{$p_id}++;
            %sub_go=&get_parent($p_id,%sub_go);
        }
    }
    return(%sub_go);
}

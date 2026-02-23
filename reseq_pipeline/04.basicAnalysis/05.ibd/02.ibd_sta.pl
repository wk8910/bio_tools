#! /usr/bin/env perl
use strict;
use warnings;

my ($ibd,$hbd)=@ARGV;
die "Usage: $0 <ibd output> <hbd output>\n" if(@ARGV<2);

my %result;
open I,"< $ibd" or die "Cannot open $ibd!\n";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($id1,$id1_idx,$id2,$id2_idx,$chr,$start,$end,$lod)=@a;
    my $len=$end-$start+1;
    $result{$id1}{$id2}+=$len;
    $result{$id2}{$id1}+=$len;
}
close I;

open I,"< $hbd" or die "Cannot open $hbd!\n";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($id1,$id1_idx,$id2,$id2_idx,$chr,$start,$end,$lod)=@a;
    my $len=$end-$start+1;
    $result{$id1}{$id2}+=$len;
}
close I;

my @id=sort keys %result;
open O,"> $0.txt";
print O "\t",join "\t",@id,"\n";
foreach my $id1(@id){
    my @line=($id1);
    foreach my $id2(@id){
	my $value=0;
	if(exists $result{$id1}{$id2}){
	    $value = $result{$id1}{$id2};
	}
	push @line,$value;
    }
    print O join "\t",@line,"\n";
}
close O;

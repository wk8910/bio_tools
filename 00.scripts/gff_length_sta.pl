#! /usr/bin/env perl
use strict;
use warnings;

my $gff=shift;

die "Usage: $0 <gff>\n" if(!$gff or !-e $gff); 

my $gene_len="$gff.geneLen.sta";
my $exon_len="$gff.exonLen.sta";
my $intron_len="$gff.intronLen.sta";
my $exon_num="$gff.exonNum.sta";

open(I,"< $gff") or die "Cannot open $gff\n";
open(O1,"> $gene_len");
open(O2,"> $exon_len");
open(O3,"> $intron_len");
open(O4,"> $exon_num");

print O1 "id\tlen\n";
print O2 "id\tlen\n";
print O3 "id\tlen\n";
print O4 "id\tnum\n";
my $control=0;
my %hash;
while(<I>){
    chomp;
    next if(/^\s*$/);
    my @a=split(/\s+/);
    my ($chr,$source,$type,$start,$end,$score,$strand,$phase,$info)=@a;
    $info=~/=([^\;\s]+)/;
    my $id=$1;
    my $len=$end-$start+1;
    if($a[2] eq "mRNA"){
	print O1 "$id\t$len\n";
    }
    elsif($a[2] eq "CDS"){
	print O2 "$id\t$len\n";
	if(!exists $hash{$id}){
	    @{$hash{$id}}=($start,$end);
	}
	else{
	    push @{$hash{$id}},($start,$end);
	}
    }
    $control++;
    # last if($control>10);
}
close I;

foreach my $id(sort keys %hash){
    my @array=sort {$a<=>$b} @{$hash{$id}};
    my $num=@array/2;
    print O4 "$id\t$num\n";
    for(my $i=1;$i<@array-1;$i+=2){
	my $start=$array[$i];
	my $end=$array[$i+1];
	my $len=$end-$start-1;
	print O3 "$id\t$len\n";
    }
}

close O1;
close O2;
close O3;
close O4;

#! /usr/bin/env perl
use strict;
use warnings;

my $fasta=shift;

die "Usage: $0 <fasta> > out.matrix" if(!-e $fasta);

my %seq;
open I,"perl ~/bio_tools/00.scripts/read_fasta.pl $fasta |";
while (my $id=<I>) {
    chomp $id;
    my $seq=<I>;
    chomp $seq;
    $id=~/^(\S+)/;
    $id=$1;
    $seq{$id}=$seq;
}
close I;

my @pop=sort keys %seq;

my %dis;
for(my $i=0;$i<@pop;$i++){
    for(my $j=$i;$j<@pop;$j++){
        my $dis=0;
        if($i != $j){
            $dis=&calculate($seq{$pop[$i]},$seq{$pop[$j]});
        }
        $dis{$i}{$j}=$dis;
        $dis{$j}{$i}=$dis;
    }
}

my @head=("",@pop);
print join "\t",@head,"\n";
for(my $i=0;$i<@pop;$i++){
    my @line=($pop[$i]);
    for(my $j=0;$j<@pop;$j++){
        my $dis=$dis{$i}{$j};
        push @line,$dis;
    }
    print join "\t",@line,"\n";
}

sub calculate{
    my ($a,$b)=@_;
    my @a=split(//,$a);
    my @b=split(//,$b);
    if(@a != @b){
        die "input must be aligned fasta!\n";
    }
    my ($total,$dis)=(0,0);
    for(my $i=0;$i<@a;$i++){
        my $x=$a[$i];
        my $y=$b[$i];
        next if($x eq "-" && $x eq $y);
        $total++;
        if($x ne $y){
            $dis++;
        }
    }
    if($total==0){
        return("NA");
    }
    else{
        return($dis/$total);
    }
}

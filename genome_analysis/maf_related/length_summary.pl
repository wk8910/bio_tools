#! /usr/bin/env perl
use strict;
use warnings;

my $maf = "gac.maf";

if($maf=~/gz$/){
    open I,"zcat $maf |";
}
else{
    open I,"< $maf";
}

my $control=0;
my %info;
while(<I>){
    chomp;
    next if(/^#/);
    my @alignment;
    if(/^a/){
        push @alignment,"$_";
        while(<I>){
            chomp;
            if(/^\s*$/){
	last;
            }
            else{
	push @alignment,"$_";
            }
        }
    }
    &read_maf(@alignment);
    # last if($control++>1);
}

close I;

open O,"> $0.txt";
foreach my $species(sort keys %info){
    my $len=$info{$species};
    print O "$species\t$len\n";
}
close O;

sub read_maf{
    my @alignment=@_;
    # print "\n\n**************************START**************************\n";
    # print join "\n",@alignment;
    # print "\n***************************END***************************\n\n";

    shift @alignment;

    # return() unless(@alignment == 5);

    foreach my $line(@alignment){
        my @elements = split /\s+/,$line;
        my($line_type,$chr,$start,$len,$strand,$chr_len,$seq)=@elements;

        my $end;
        if($strand eq "+"){
            $start = $start + 1;
            $end = $start + $len - 1;
        }
        else{
            $start = $chr_len - $start;
            $end = $start - $len + 1;

            my $temp = $start;
            $start = $end;
            $end = $temp;
        }

        $chr=~/^(\w+)\./;
        my $species=$1;
        # print "$species\n";
        $info{$species}+=$len;
    }
}

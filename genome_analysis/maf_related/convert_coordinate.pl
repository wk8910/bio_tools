#! /usr/bin/env perl
use strict;
use warnings;

my $maf="cattle.maf";
my $out="point2point.lst.gz";
my $species_num=5;

open(I,"< $maf") or die "Cannot open $maf!\n";
open(O,"| gzip -> $out") or die "Cannot create $out!\n";
my $total_length=0;
my $control=0;
while(<I>){
    # last if($control > 1000);
    print STDERR "$control\t$total_length\r";
    next if(/^#/);
    chomp;

    my %align;

    # Read a section of maf
    my @a=split(/\s+/);
    next unless($a[0] eq "a");
    my $num_of_species = 0;
    my $chr_here;
    while (<I>) {
        my @line=split(/\s+/);
        last if(@line != 7);
        my ($type,$source,$start,$size,$strand,$chr_length,$seq) = @line;
        $source=~/^(\w+)\.(.*)/;
        my ($species,$chr) = ($1,$2);
        $chr_here=$chr if($species eq "cattle");
        $num_of_species++;
        $align{$species}{seq} = $seq;
        $align{$species}{strand} = $strand;
        $align{$species}{size} = $size;
        $align{$species}{chr} = $chr;
        $align{$species}{start}=$start;
        $align{$species}{chr_length} = $chr_length;
    }
    # Read complete

    next if($num_of_species < $species_num); # next if number of species less than 5
    # last if($chr_here ne "12");
    my $real_length=&length_stat(\%align);
    next if($real_length < 10);
    $total_length+=$real_length;
    $control++;
}
close I;
close O;

sub length_stat{
    my $hash_transmit = shift;
    my %align = %{$hash_transmit};

    my $longest_size=0;
    my $real_length=0;
    my %coordinate;
    my %available_sites;

    foreach my $species(keys %align){
        $longest_size = $align{$species}{size} if($longest_size < $align{$species}{size});
    }

    if($longest_size < 10){
        return($longest_size);
    }
    else {
        my %seq;
        foreach my $species(keys %align){
            my @seq=split("",$align{$species}{seq});
            $seq{$species}=[@seq];
        }

        my %anchor;
        for(my $i=0;$i<$longest_size;$i++){
            my %bases;
            my @bases;
            my $light=1;
            foreach my $species(keys %seq){
	my $base=uc($seq{$species}[$i]);
	$bases{$species}=$base;
	if($base eq "N" || $base eq "-"){
	    $light=0;
	}
	if($base ne "-") {
	    $anchor{$species}++;
	}
	$coordinate{$species}{$i}=$anchor{$species};
            }
            if($light==1){
	$real_length++;
	$available_sites{$i}=1;
            }
        }
    }
    if($real_length>=10){
        foreach my $i(sort {$a<=>$b} keys %available_sites){
            my @line;
            foreach my $species(sort keys %coordinate){
	my $start=$align{$species}{start};
	my $chr=$align{$species}{chr};
	my $strand=$align{$species}{strand};
	my $chr_length=$align{$species}{chr_length};
	my $anchor=$coordinate{$species}{$i};
	my $real_pos;
	if($strand eq "+"){
	    $real_pos=$start+($anchor-1);
	}
	elsif ($strand eq "-") {
	    # $real_pos=$start+$seq_length-$anchor;
	    $real_pos=($chr_length-1)-$start-($anchor-1);
	}
	push @line,($species,$chr,$strand,$real_pos);
            }
            print O join "\t",@line,"\n";
        }
    }
    print O "\n";
    return($real_length);
}

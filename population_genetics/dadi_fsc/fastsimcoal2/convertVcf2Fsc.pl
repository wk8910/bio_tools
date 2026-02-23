#! /usr/bin/env perl
use strict;
use warnings;

my ($vcf,$popList,$totalLength,$outputPrefix)=@ARGV;
die "
Usage: $0 <vcf> <pop list> <total length of sequences> <output prefix>\n
NOTE 1: vcf should be gzip compressed!\n
NOTE 2: pop list file should be formatted like this:
sampleID\tpopID\tfscID\nfscID should start from 0, if fscID=-1, this ind will be recognized as outgroup\n
" if(@ARGV != 4);

open(I,"< $popList") or die "Cannot open $popList!\n";
my %popIndNum;
my %sid2pid;
my $largestFscId=-2;
while (<I>) {
    chomp;
    next if(/^#/);
    my @a=split(/\s+/);
    my ($sid,$pid,$fid)=@a;
    $popIndNum{$fid}{$sid} = 1;
    $sid2pid{$sid} = $fid;
    $largestFscId = $fid if($largestFscId < $fid);
}
close I;

my $outgroupThreshold=0;
if(exists $popIndNum{"-1"}){
    my $indNum=keys %{$popIndNum{"-1"}};
    my $hapNum=$indNum * 2;
    my $outgroupThreshold=int($hapNum * 0.8)+1;
}
else {
    print STDERR "Warning!\nNo outgroup specified, the output spectrum should be folded before it can be used for further analysis\n";
}

my %alleleFrequencySpectrum;

for(my $i=$largestFscId;$i>=1;$i--){
    my $firstPopIndNum=0;
    my $secondPopIndNum=0;
    if(!exists $popIndNum{$i}){
        die "Cannot find population with FSC id $i!\n";
    }
    else {
        $firstPopIndNum=keys %{$popIndNum{$i}};
    }
    for(my $j=$i-1;$j>=0;$j--){
        if(!exists $popIndNum{$i}){
            die "Cannot find population with FSC id $i!\n";
        }
        else {
            $secondPopIndNum=keys %{$popIndNum{$j}};
        }

        for(my $d_i=0;$d_i<=$firstPopIndNum * 2;$d_i++){
            for(my $d_j=0;$d_j<=$secondPopIndNum * 2;$d_j++){
	$alleleFrequencySpectrum{$i}{$j}{$d_i}{$d_j}=0;
            }
        }
    }
}

open(I,"zcat $vcf |") or die "Cannot open $vcf!\n";
my @head;
while (<I>) {
    next if(/^##/);
    if(/^#/){
        chomp;
        @head=split(/\s+/);
        last;
    }
}

my $control=0;
while (<I>) {
    next if(/\.\/\./);
    # last if($control++>=100000);
    chomp;
    my @a=split(/\s+/);
    my %popAndSite;
    for(my $i=9;$i<@a;$i++){
        my $sid=$head[$i];
        my $fid=$sid2pid{$sid};
        $a[$i]=~/(\d)\/(\d)/;
        my $altNum=$1+$2;
        if(!exists $popAndSite{$fid}){
            $popAndSite{$fid}=0;
        }
        $popAndSite{$fid}=$popAndSite{$fid}+$altNum;
    }
    if($outgroupThreshold > 0){
        if($popAndSite{"-1"} > $outgroupThreshold){
            for(my $i=0;$i<=$largestFscId;$i++){
	my $popIndNum=keys %{$popIndNum{$i}};
	$popAndSite{$i}=($popIndNum * 2)-$popAndSite{$i};
            }
        }
        elsif ($popAndSite{"-1"} > 1-$outgroupThreshold) {
            next;
        }
    }
    for(my $i=$largestFscId;$i>=1;$i--){
        my $d_i=$popAndSite{$i};
        for(my $j=$i-1;$j>=0;$j--){
            my $d_j=$popAndSite{$j};
            $alleleFrequencySpectrum{$i}{$j}{$d_i}{$d_j}++;
        }
    }
}
close I;

for(my $i=$largestFscId;$i>=1;$i--){
    my $num_i=keys %{$popIndNum{$i}};
    $num_i=$num_i * 2;
    for(my $j=$i-1;$j>=0;$j--){
        my $num_j=keys %{$popIndNum{$j}};
        $num_j=$num_j * 2;
        my $siteTotalNumber=0;
        foreach my $d_i(keys %{$alleleFrequencySpectrum{$i}{$j}}){
            foreach my $d_j(keys %{$alleleFrequencySpectrum{$i}{$j}{$d_i}}){
	my $num=$alleleFrequencySpectrum{$i}{$j}{$d_i}{$d_j};
	$siteTotalNumber+=$num;
            }
        }

        if($totalLength < $siteTotalNumber){
            print STDERR "WARNING: The total length must be wrong!\n";
        }
        $alleleFrequencySpectrum{$i}{$j}{0}{0} = $totalLength + $alleleFrequencySpectrum{$i}{$j}{0}{0} - $siteTotalNumber;

        print STDERR "$i\t$j\t$siteTotalNumber\n";

        my $outfileName=$outputPrefix."_jointDAFpop$i"."_$j.obs";
        open(O,"> $outfileName") or die "Cannot create $outfileName!\n";
        print O "1 observation\n";
        my @colTitle=("");
        for(my $y=0;$y<=$num_j;$y++){
            my $colName="d".$j."_".$y;
            push @colTitle,$colName;
        }
        print O join "\t",@colTitle,"\n";
        for(my $x=0;$x<=$num_i;$x++){
            my $rowName="d".$i."_".$x;
            my @row=($rowName);
            for(my $y=0;$y<=$num_j;$y++){
	my $siteNumber=$alleleFrequencySpectrum{$i}{$j}{$x}{$y};
	push @row,$siteNumber;
            }
            print O join "\t",@row,"\n";
        }
        close O;
    }
}

#!/usr/bin/perl
use strict;
use warnings;

## created by Yang Yongzhi. Indel just filter the quality less than 30. SNPs were filtered meeting the following criteria: Quality score less than 20; SNPs within 5bp around an indel; The read depths (RD) less than 1/3 fold or more than 3 fold average depth. Multi-nucleotide polymorphisms; Mapping Quality less than 30; The Phred scaled base quality less than 20###

my $invcf=shift;
my $outvcf=shift;
die "Usage:\n$0 invcf outvcf\n" if (! $outvcf);
my ($IndelQ,$SNPQ,$indelDIS,$RDmin,$RDmax,$MQ)=(20,20,5,1/3,4,30);

my %fail;
my %dp=&readdepth();
my @id;
my %indel;

open(F,"zcat $invcf|")||die"$!";
while (<F>) {
    chomp;
    my @a=split(/\t/,$_);
    @id=@a if /^#CHROM/;
    next if /^#/;
    my $type='snp';
    my @var=split(/,/,$a[4]);
    push @var,$a[3];
    ###INDELs/SNPs quality less than 20###
    next if $a[5]<20;
    
    if ($a[7]=~/INDEL/){
        $type='INDEL';
    }else{
        foreach my $var(@var){
            my $len=length($var);
            if($len>1){
	$type='INDEL';
            }
        }
    }
    
    if ($type eq 'INDEL'){
        $indel{$a[0]}{$a[1]}++;
        next if $a[5] < 30;
        for (my $i=$a[1]-$indelDIS;$i<=$a[1]+$indelDIS;$i++){
            next if $i == $a[1];
            $fail{$a[0]}{$i}++;
        }
    }
}
close F;

open(F,"zcat $invcf|")||die"$!";
open(O,"| gzip -c - > $outvcf")||die"$!";
while (<F>) {
    chomp;
    if (/^#/){
        print O "$_\n";
        next;
    }
    my @a=split(/\t/,$_);
    ###SNPs less than 20###
    if ($a[5]<20){
        next;
    }
    ###SNPs within 5bp around an indel###
    next if exists $fail{$a[0]}{$a[1]};
    ###Remove INDELs###
    next if exists $indel{$a[0]}{$a[1]};
    ###Multi-nucleotide polymorphisms###
    next if ((length($a[3])>1) || (length($a[4])>1));
    
    ###Mapping Quality less than 30###
    if ($a[7]=~/MQ=(\d+)/){
        if ($1<30){
            next;
        }
    }
    ###The read depths (RD) less than 1/3 fold or more than 3 fold average depth ###
    my @infotype=split(/\:/,$a[8]);
    my $miss=0;
    for (my $i=9;$i<@a;$i++){
        my @info=split(/\:/,$a[$i]);
        die "there is no dp information of individual $id[$i] in the dp file\n" if (! exists $dp{$id[$i]});
        my $mindp=int($dp{$id[$i]} * $RDmin);
        my $maxdp=$dp{$id[$i]} * $RDmax;
        $maxdp=int($maxdp)+1 if ($maxdp > int($maxdp));
        
        my $check=0;
        for (my $j=0;$j<@infotype;$j++){
            if ($infotype[$j] eq 'DP'){
	$check++;
	if ($info[$j]<$mindp || $info[$j]>$maxdp){
	    $a[$i]="./.";
	}
            }
        }
        $a[$i]="./." if $check == 0;
        $miss++ if $a[$i] eq './.';
    }
    next if $miss == scalar(@a) - 9;
    print O join("\t",@a),"\n";
}
close F;
close O;

sub readdepth{
    my %r;
    open (F,"00.depth.list")||die"no depth file 00.depth.list\n";
    while (<F>) {
        chomp;
        my @a=split(/\s+/,$_);
        next if /^(#|ID)/;
        $r{$a[0]}=$a[1];#$a[3]/$a[2];
    }
    close F;
    return %r;
}

#! /usr/bin/env perl
use strict;
use warnings;

my $point="point2point.lst.gz";
my $gff_dir="gff";
my $ref="gac";
my $out="$0.txt";

my %cds_sites;
my %gene;
my %len;
my @gff=<$gff_dir/*.gff>;
foreach my $gff(@gff){
    $gff=~/([^\/]+).gff$/;
    my $species_id=$1;
    open I,"< $gff";
    while(<I>){
        chomp;
        my @a=split(/\s+/);
        next unless($a[2] eq "CDS");
        my ($chr,$start,$end,$strand)=($a[0],$a[3],$a[4],$a[6]);
        $a[8]=~/Parent=(\w+)/;
        my $id=$1;
        for(my $i=$start;$i<=$end;$i++){
            $cds_sites{$species_id}{$chr}{$i}=$id;
            $gene{$species_id}{$id}{pos}{$i}=0;
        }
        $gene{$species_id}{$id}{strand}=$strand;
        if($species_id eq $ref){
            $len{$id}+=$end-$start+1;
        }
    }
    close I;
    print STDERR "gff $species_id loaded...\n";
}

my %light;
open I,"zcat $point |";
while (<I>) {
    chomp;
    next if(/^\s*$/);
    my @a=split(/\s+/);
    my $light=1;
    my ($ref_chr,$ref_pos,$ref_strand,$ref_gene);
    my %strand;
    for(my $i=0;$i<@a;$i+=4){
        my ($species_id,$chr,$strand,$pos)=($a[$i],$a[$i+1],$a[$i+2],$a[$i+3]);
        next if(!exists $gene{$species_id});
        if($species_id eq $ref){
            $ref_chr=$chr;
            $ref_pos=$pos;
            $ref_strand=$strand;
        }
        if(!exists $cds_sites{$species_id}{$chr}{$pos}){
            $light=0;
        }
        else {
            my $gene_id=$cds_sites{$species_id}{$chr}{$pos};
            if($species_id eq $ref){
	$ref_gene = $gene_id;
            }
            my $gene_strand=$gene{$species_id}{$gene_id};
            if($gene_strand ne $strand){
	$strand{minus}++;
            }
            else {
	$strand{plus}++;
            }
        }
    }
    if(!$ref_chr){
        die "$ref could not found in point to point file!\n";
    }
    next if($light==0);
    next if(keys %strand > 1);
    $light{$ref_gene}++;
    print STDERR "$ref_gene found \r";
}
close I;

open O,"> $out";
foreach my $gene_id(sort keys %len){
    my $len=$len{$gene_id};
    my $effective_len=0;
    if(exists $light{$gene_id}){
        $effective_len=$light{$gene_id};
    }
    print O "$gene_id\t$len\t$effective_len\n";
}
close O;

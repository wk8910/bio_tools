#! /usr/bin/perl
use strict;
use warnings;

my $gff=shift or die "perl $0 <GCF_001970005.1_Flounder_ref_guided_V1.0_genomic.gff>";
my $out="clean.gff";

my %length;
my %gene_cds;
open I,"< $gff";
while (<I>) {
    next if(/^#/);
    my @a=split(/\s+/);
    my ($chr,$source,$type,$start,$end,$score,$strand,$phase,$info)=@a;
    if($type eq "CDS"){
        $info=~/Parent=([^;]+)/;
        my $cds_id=$1;
        $length{$cds_id}+=$end-$start+1;
    }
    elsif($type eq "mRNA"){
        $info=~/ID=([^;]+).*Parent=([^;]+)/;
        my ($cds_id,$gene_id)=($1,$2);
        $gene_cds{$gene_id}{$cds_id}=1;
    }
}
close I;

foreach my $gene_id(keys %gene_cds){
    foreach my $cds_id(keys %{$gene_cds{$gene_id}}){
        if(exists $length{$cds_id}){
            $gene_cds{$gene_id}{$cds_id}=$length{$cds_id};
        }
        else {
            delete $gene_cds{$gene_id}{$cds_id};
        }
    }
}

my %keep;
foreach my $gene_id(sort keys %gene_cds){
    my @protein_id=sort {$gene_cds{$gene_id}{$b} <=> $gene_cds{$gene_id}{$a}} keys %{$gene_cds{$gene_id}};
    my $selected=$protein_id[0];
    # $selected=~s/\.\d$//;
    $keep{$selected}=1;
}

open O,"> $out";
open I,"< $gff";
while (<I>) {
    chomp;
    next if(/^#/);
    my @a=split(/\s+/);
    my ($chr,$source,$type,$start,$end,$score,$strand,$phase,$info)=@a;
    if($type eq "CDS"){
        $info=~/Parent=([^;]+)/;
        my $cds_id=$1;
        next unless($keep{$cds_id});
        s/transcript://g;
        print O "$_\n";
    }
    elsif($type eq "mRNA"){
        $info=~/ID=([^;]+).*Parent=([^;]+)/;
        my ($cds_id,$gene_id)=($1,$2);
        next unless($keep{$cds_id});
        s/transcript://g;
        print O "$_\n";
    }
}
close I;
close O;

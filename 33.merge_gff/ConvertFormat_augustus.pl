#! /usr/bin/env perl
use strict;
use warnings;

my ($input,$output)=@ARGV;
die "Usage: $0 <input gff> <output gff>" if(@ARGV<2);

my %gff;

my %exon;
my $geneid;
my $start;
open(I,"< $input") or die "Cannot open $input\n";
while (<I>) {
    chomp;
    next if(/^#/);
    next if /^$/;
    my @a=split(/\t/);

    if($a[3]>$a[4]){
        my $tmp=$a[4];
        $a[4]=$a[3];
        $a[3]=$tmp;
    }
    $a[1]=lc($a[1]);
    if ($a[2] eq 'gene'){
        $geneid=$a[8];
        $start=$a[3];
        $a[8]="ID=$a[8]";
        $gff{$a[0]}{$start}{$geneid}{gff} .= join("\t",@a)."\n";
    }elsif($a[2] eq 'transcript'){
        $a[8]="ID=$a[8];Parent=$geneid";
        $a[2]="mRNA";
        $gff{$a[0]}{$start}{$geneid}{gff} .= join("\t",@a)."\n";
    }elsif($a[2] eq 'exon'){
        $a[8]=~/transcript_id\s+\"([^\"]+)\";\s+gene_id\s+\"([^\"]+)\";/ or die "$_\n";
        $exon{$1}++;
        $a[8]="ID=$1.exon$exon{$1};Parent=$1";
        $gff{$a[0]}{$start}{$geneid}{gff} .= join("\t",@a)."\n";
    }elsif($a[2] eq 'CDS'){
        $a[8]=~/transcript_id\s+\"([^\"]+)\";\s+gene_id\s+\"([^\"]+)\";/ or die "$_\n";
        $a[8]="ID=cds.$1;Parent=$1";
        $gff{$a[0]}{$start}{$geneid}{gff} .= join("\t",@a)."\n";
        $gff{$a[0]}{$start}{$geneid}{len} += abs($a[4]-$a[3])+1;
    }
}
close I;

open(O,"> $output") or die "Cannot create $output\n";
foreach my $chr(sort keys %gff){
    for my $pos (sort{$a<=>$b} keys %{$gff{$chr}}){
        for my $gene (sort keys %{$gff{$chr}{$pos}}){
            next if $gff{$chr}{$pos}{$gene}{len} < 150;
            print O "$gff{$chr}{$pos}{$gene}{gff}";
        }
    }
}
close O;

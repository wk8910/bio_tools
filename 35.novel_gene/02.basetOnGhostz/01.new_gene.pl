#! /usr/bin/env perl
use strict;
use warnings;

my $fasta="goodProteins.fasta";
my $blast="all_blast.out";
my $out="potential.lst";

my %hash;
open I,"perl ~/bio_tools/00.scripts/read_fasta.pl $fasta |";
while (my $id=<I>) {
    chomp $id;
    my $seq=<I>;
    chomp $seq;
    $id=~/^(\w+)\|(.*)/;
    my ($species_id,$gene_id)=($1,$2);
    $hash{$species_id}{$gene_id}=1;
}
close I;

open I,"< $blast";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($a,$b)=($a[0],$a[1]);
    $a=~/^(\w+)\|(.*)/;
    my ($a_species_id,$a_gene_id)=($1,$2);
    $b=~/^(\w+)\|(.*)/;
    my ($b_species_id,$b_gene_id)=($1,$2);
    if($a_species_id ne $b_species_id){
        $hash{$a_species_id}{$a_gene_id}=0;
    }
}
close I;

open O,"> $out";
foreach my $species_id(sort keys %hash){
    foreach my $gene_id(sort keys %{$hash{$species_id}}){
        next if($hash{$species_id}{$gene_id}==0);
        print O "$species_id\t$gene_id\n";
    }
}
close O;

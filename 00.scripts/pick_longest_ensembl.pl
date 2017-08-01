#! /usr/bin/perl
# This script is used to reading fasta file without the help of BioPerl
use strict;
use warnings;

my $file=shift;
my $out="$file.clean.fas";
my $log="$file.log";
my $tool="/home/share/users/wangkun2010/bio_tools/00.scripts/read_fasta.pl";

my %hash;
open(I,"perl $tool $file |");
while (my $id=<I>) {
    chomp $id;
    my $seq=<I>;
    chomp $seq;
    $id=~/^(\S+)/;
    my $protein_id=$1;
    $id=~/gene:([^\s\.]+)/;
    my $gene_id=$1;
    my $len=length($seq);
    $hash{$gene_id}{$protein_id}=$len;
}
close I;

my %keep;
foreach my $gene_id(sort keys %hash){
    my @protein_id=sort {$hash{$gene_id}{$b} <=> $hash{$gene_id}{$a}} keys %{$hash{$gene_id}};
    my $selected=$protein_id[0];
    $keep{$selected}=1;
}

open O,"> $out";
open L,"> $log";
open(I,"perl $tool $file |");
while (my $id=<I>) {
    chomp $id;
    my $seq=<I>;
    chomp $seq;
    # print ">$id\n$seq\n";
    $id=~/^(\S+)/;
    my $protein_id=$1;
    next unless(exists $keep{$protein_id});
    $id=~/gene:([^\s\.]+)/;
    my $gene_id=$1;
    print L "$gene_id\t$protein_id\n";
    print O ">$gene_id\n$seq\n";
}
close I;
close O;
close L;

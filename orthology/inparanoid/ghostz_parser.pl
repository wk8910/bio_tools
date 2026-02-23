#! /usr/bin/env perl
use strict;
use warnings;

my ($query,$ref,$blast)=@ARGV;
die "Usage: $0 <query_pep> <ref_pep> <ghostz out>\n" if(@ARGV<3);

my %len;
$/=">";

open(I,"< $query");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    $id=~/^(\S+)/;
    $id=$1;
    my $seq=join "",@lines;# the sequence of fasta is $seq
    my $len=length($seq);
    $len{$id}=$len;
}
close I;

open(I,"< $ref");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    $id=~/^(\S+)/;
    $id=$1;
    my $seq=join "",@lines;# the sequence of fasta is $seq
    my $len=length($seq);
    $len{$id}=$len;
}
close I;

$/="\n";

if(-e "$blast"){
    open I,"< $blast";
    while (<I>) {
        chomp;
        my @a=split(/\s+/);
        my ($query_id,$hit_id,$identity,$alignment_len,$mismatches,$gap,$q_start,$q_end,$h_start,$h_end,$evalue,$bitscore)=@a;
        my $q_len=$len{$query_id};
        my $h_len=$len{$hit_id};
        my $q_aln_len=$q_end-$q_start+1;
        my $h_aln_len=$h_end-$h_start+1;
        my $info="q:$q_start-$q_end h:$h_start-$h_end";
        my @line=($query_id,$hit_id,$bitscore,$q_len,$h_len,$q_aln_len,$h_aln_len,$q_aln_len,$h_aln_len,$info);
        print join "\t",@line,"\n";
    }
    close I;
}
else {
    print STDERR "$blast does not exists!\n";
}

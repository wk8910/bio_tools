#! /usr/bin/perl
# This script is used to fix consensus fasta
# Command for generate consensus fa: angsd -i ancestor.bam -only_proper_pairs 1 -uniqueOnly 1 -remove_bads 1 -nThreads 5 -minQ 20 -minMapQ 30 -doFasta 2 -basesPerLine 100 -doCounts 1 -out ancestor
use strict;
use warnings;

my ($origin,$consensus) = @ARGV;
die "Usage: $0 <origin fa> <consensus fa>\n" if(@ARGV<2);

$/=">";
my %len;
my @id;
open(I,"< $origin");
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
    push @id,$id;
}
close I;
$/="\n";

$/=">";
my %fasta;
open(I,"< $consensus");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    $id=~/^(\S+)/;
    $id=$1;
    my $seq=join "",@lines;# the sequence of fasta is $seq
    my $len=length($seq);
    $fasta{$id}=$seq;
}
close I;
$/="\n";

open O,"> $consensus.fix.fa";
foreach my $id(@id){
    my $origin_len = $len{$id};
    my $consensus_len = 0;
    my $consensus_seq = "";
    if(exists $fasta{$id}){
	$consensus_seq = $fasta{$id};
	$consensus_len = length($consensus_seq);
    }
    my $distance = $origin_len - $consensus_len;
    my $add_base = "N" x $distance;
    $consensus_seq = $consensus_seq.$add_base;
    print O ">$id\n$consensus_seq\n";
}
close O;

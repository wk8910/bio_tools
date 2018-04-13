#! /usr/bin/perl
# This script is used to reading fasta file without the help of BioPerl
use strict;
use warnings;

my ($scaffold,$start,$end,$strand)=@ARGV;
$/=">";
if(!$strand){
    $strand="+";
}

my $file="scaffolds/$scaffold.fa";
open(I,"< $file");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    $id=~/^(\S+)/;
    $id=$1;
    my $seq=join "",@lines;# the sequence of fasta is $seq
    my $len=$end-$start+1;
    # print "$len\n";
    my $x=$start-1;
    my $subseq=substr($seq,$x,$len);
    if($strand eq "-"){
        $subseq=reverse($subseq);
        $subseq=~tr/ATCGatcg/TAGCtagc/;
    }
    print ">${id}_${start}_${end}_${strand}\n$subseq\n";
 }
close I;
$/="\n";

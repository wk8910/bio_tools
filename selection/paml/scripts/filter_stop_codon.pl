#! /usr/bin/perl
# This script is used to reading fasta file without the help of BioPerl
use strict;
use warnings;

my ($file,$out_prefix)=@ARGV;
die "Usage: $0 <aligned fasta 3 by 3> <output prefix>" if(@ARGV < 2);

my $out="$out_prefix.fa";
my $log="$out_prefix.log";

$/=">";

my %light;
open(I,"< $file");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    my $seq=join "",@lines;# the sequence of fasta is $seq
    $seq=uc($seq);
    $seq=~s/U/T/g;
    my @base=split(//,$seq);
    for(my $i=0;$i<@base;$i+=3){
        next if(!$base[$i] or !$base[$i+1] or !$base[$i+2]);
        my $codon=$base[$i].$base[$i+1].$base[$i+2];
        if(!exists $light{$i}){
            $light{$i}=1;
        }
        if($codon=~/-/){
            $light{$i}=0;
        }
        if($codon=~/TAA|TGA|TAG/){
            $light{$i}=0;
        }
    }
}
close I;

open L,"> $log";
my $codon_num=0;
foreach my $i(sort {$a<=>$b} keys %light){
    if($light{$i}==1){
        $codon_num++;
    }
    print L "$i\t$light{$i}\t$codon_num\n";
}
close L;

open O,"> $out";
open(I,"< $file");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;# the name of fasta is $id
    my $seq=join "",@lines;# the sequence of fasta is $seq
    $seq=uc($seq);
    my @base=split(//,$seq);
    my $newseq;
    for(my $i=0;$i<@base;$i+=3){
        next if(!$base[$i] or !$base[$i+1] or !$base[$i+2]);
        my $codon=$base[$i].$base[$i+1].$base[$i+2];
        if($light{$i}==1){
            $newseq.=$codon;
        }
    }
    print O ">$id\n$newseq\n";
}
close O;


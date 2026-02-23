#! /usr/bin/env perl
use strict;
use warnings;

my $dir="/data2/home/humingliang/download/sterlet/trans_reads/";

my @fq1=<$dir/*/*1.fastq.gz>;

open O,"> $0.sh";
foreach my $fq1(@fq1){
    my $fq2=$fq1;
    $fq2=~s/1\.fastq/2.fastq/;
    $fq1=~/(\w+)_1\.fastq/;
    my $id=$1;
    next if(-e "$id/transcripts.fasta");
    print O "~/software/transcriptome_assembly/rnaspades/SPAdes-3.14.0-Linux/bin/rnaspades.py -1 $fq1 -2 $fq2 -o $id 1> $id.log 2> $id.err\n";
}
close O;

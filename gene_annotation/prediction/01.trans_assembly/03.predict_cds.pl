#! /usr/bin/env perl
use strict;
use warnings;

my @cds=<*/transcripts.fasta>;

open O,"> $0.sh";
foreach my $cds(@cds){
    $cds=~/(.*)\/([^\/]+)$/;
    my $dir=$1;
    print O "cd $dir; /public/home/wangkun/software/transcriptome_assembly/transdecoder/TransDecoder-TransDecoder-v5.5.0/TransDecoder.LongOrfs -t transcripts.fasta; /public/home/wangkun/software/transcriptome_assembly/transdecoder/TransDecoder-TransDecoder-v5.5.0/TransDecoder.Predict -t transcripts.fasta; cd -\n";
}
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my @bam=<01.bamBySample/*.bam>;
my $outdir="02.bamRmdup";
`mkdir $outdir` if(!-e $outdir);

open(O,"> $0.sh");
foreach my $bam(@bam){
    $bam=~/([^\/]+)\.bam$/;
    my $name=$1;
    # print O "/home/share/software/java/jdk1.8.0_05/bin/java -Xmx10g -jar /home/share/user/user101/software/picard/picard-tools-2.0.1/picard.jar MarkDuplicates INPUT=$now/$bam OUTPUT=$now/$outdir/$name.bam METRICS_FILE=$now/$outdir/$name.dup.txt REMOVE_DUPLICATES=true\n";
    print O "/home/share/user/user101/bin/samtools rmdup $now/$bam $now/$outdir/$name.bam\n";
}
close O;

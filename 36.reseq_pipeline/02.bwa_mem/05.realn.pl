#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my @bam=<02.bamRmdup/*.bam>;
my $outdir="03.realnBam";
`mkdir $outdir` if(!-e $outdir);

open(O,"> $0.sh");
foreach my $bam(@bam){
    $bam=~/([^\/]+)\.bam$/;
    my $name=$1;
    # print O "/home/share/software/java/jdk1.8.0_05/bin/java -Xmx10g -jar /home/share/user/user101/software/GATK/GenomeAnalysisTK.jar -R /home/share/user/user101/projects/yangshu/11.ref/ptr.fa -T RealignerTargetCreator -o $now/$outdir/$name.intervals -I $now/$bam; /home/share/software/java/jdk1.8.0_05/bin/java -Xmx10g -jar /home/share/user/user101/software/GATK/GenomeAnalysisTK.jar -R /home/share/user/user101/projects/yangshu/11.ref/ptr.fa -T IndelRealigner -targetIntervals $now/$outdir/$name.intervals -o $now/$outdir/$name.bam -I $now/$bam\n";
    print O "/home/share/software/java/jdk1.8.0_05/bin/java -Xmx10g -jar /home/share/user/user101/software/GATK/GenomeAnalysisTK.jar -R /home/share/user/user101/projects/yangshu/11.ref/ptr.fa -T IndelRealigner -targetIntervals $now/$outdir/$name.intervals -o $now/$outdir/$name.bam -I $now/$bam\n";
}
close O;

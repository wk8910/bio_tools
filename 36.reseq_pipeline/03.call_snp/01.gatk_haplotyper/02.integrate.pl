#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my $input_dir="01.vcfByind";
my $out_dir="02.vcfByWind";
`mkdir $out_dir` if(!-e $out_dir);

my @wind=<$input_dir/*>;

open(O,"> $0.sh");
foreach my $wind(@wind){
    #print "$wind\n";
    $wind=~/(\w+)$/;
    my $name=$1;
    # print "$name\n";
    # print "$wind\n";
    my @vcf=<$now/$wind/*.vcf.gz>;
    foreach my $vcf(@vcf){
	$vcf="--variant ".$vcf;
    }
    my $variant=join " ",@vcf;
    my $cmd="/home/share/software/java/jdk1.8.0_05/bin/java -jar /home/share/user/user101/software/GATK/nightly/GenomeAnalysisTK.jar -T GenotypeGVCFs -R /home/share/user/user101/projects/yangshu/11.ref/ptr.fa -L $now/$wind/intervals.list $variant -o $now/$out_dir/$name.vcf.gz --includeNonVariantSites -nt 12\n";
    # print "$cmd\n";
    print O "$cmd";
    # last;
}
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $ref = "/mnt/disk1/yanbiyao2016/02.bamfile/UMD3.1_chromosomes.fa";
my $now=$ENV{'PWD'};
my $input_dir="01.step1_gvcf";
my $out_dir="02.step2_combine";
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
    my $cmd="/home/share/users/zhangxu2011/software/jre1.8.0_101/bin/java -jar /home/share/users/zhangxu2011/software/GenomeAnalysisTK.jar -T GenotypeGVCFs -R $ref -L $now/$wind/intervals.list $variant -o $now/$out_dir/$name.vcf.gz --includeNonVariantSites -nt 12\n";
    # print "$cmd\n";
    print O "$cmd";
    # last;
}

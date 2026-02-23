#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my $ref = "/mnt/disk1/yanbiyao2016/02.bamfile/UMD3.1_chromosomes.fa";
my $dict="/mnt/disk1/yanbiyao2016/02.bamfile/UMD3.1_chromosomes.fa.dict";
my @bam=</mnt/disk1/yanbiyao2016/02.bamfile/BWA_UMD3.1.Rehead.Realign/*.bam>;
my $output_dir="01.step1_gvcf";
`mkdir $now/$output_dir` if(!-e "$now/$output_dir");
my $outlier=1000000;

open(O,"> $0.sh");
my $output_id=0;
`mkdir $now/$output_dir/$output_id` if(!-e "$now/$output_dir/$output_id");
open(L,"> $now/$output_dir/$output_id/intervals.list");
foreach my $bam(@bam){
	$bam=~/([^\/]+)\.realn\.bam$/;
	my $sample_id=$1;
	print O "/home/share/users/zhangxu2011/software/jre1.8.0_101/bin/java -jar /home/share/users/zhangxu2011/software/GenomeAnalysisTK.jar -T HaplotypeCaller -R $ref -I $bam -L $now/$output_dir/$output_id/intervals.list -ERC GVCF -o $now/$output_dir/$output_id/$sample_id.vcf.gz -variant_index_type LINEAR -variant_index_parameter 128000 2>&1 | tee $now/$output_dir/$output_id/$sample_id.$output_id.log\n";
}

my $accumulate=0;
open(I,"< $dict");
while(<I>){
    chomp;
    next unless(/SN:(\S+)\s+LN:(\d+)/);
    my ($chr,$len)=($1,$2);
    my $left=$len;
    my $start_pos=1;
    while($left>0){
	if($accumulate >= $outlier){
	    $output_id ++;
	    close L;
	    `mkdir $now/$output_dir/$output_id` if(!-e "$now/$output_dir/$output_id");
	    open(L,"> $now/$output_dir/$output_id/intervals.list");
	    foreach my $bam(@bam){
		$bam=~/([^\/]+)\.realn\.bam$/;
		my $sample_id=$1;
		print O "/home/share/users/zhangxu2011/software/jre1.8.0_101/bin/java -jar /home/share/users/zhangxu2011/software/GenomeAnalysisTK.jar -T HaplotypeCaller -R $ref -I $bam -L $now/$output_dir/$output_id/intervals.list -ERC GVCF -o $now/$output_dir/$output_id/$sample_id.vcf.gz -variant_index_type LINEAR -variant_index_parameter 128000 2>&1 | tee $now/$output_dir/$output_id/$sample_id.$output_id.log\n";
	    }
	    $accumulate = 0;
	}
	my $cut_length = $outlier-$accumulate;
	if($cut_length <= $left){
	    $left -= $cut_length;
	}
	else{
	    $cut_length=$left;
	    $left=0;
	}
	$accumulate+=$cut_length;
	my $end_pos=$cut_length+$start_pos-1;
	print "$output_id\tlen: $len\tcut_length: $cut_length\tleft: $left\taccumulate: $accumulate\t$chr:$start_pos-$end_pos\n";
	print L "$chr:$start_pos-$end_pos\n";

	$start_pos+=$cut_length;
    }
}
close I;
close L;
close O;

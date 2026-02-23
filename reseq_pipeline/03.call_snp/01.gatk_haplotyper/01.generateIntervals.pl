#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my $dict="/home/share/user/user101/projects/yangshu/11.ref/ptr.dict";
my @bam=</home/share/user/user101/projects/yangshu/12.alignment/03.realnBam/*.bam>;
my $output_dir="01.vcfByind";
`mkdir $now/$output_dir` if(!-e "$now/$output_dir");
my $outlier=1000000;

open(O,"> $0.sh");
my $output_id=0;
`mkdir $now/$output_dir/$output_id` if(!-e "$now/$output_dir/$output_id");
open(L,"> $now/$output_dir/$output_id/intervals.list");
foreach my $bam(@bam){
    next if($bam=~/pro01-b/);
    $bam=~/([^\/]+)\.bam$/;
    my $sample_id=$1;
    print O "/home/share/software/java/jdk1.8.0_05/bin/java -jar /home/share/user/user101/software/GATK/GenomeAnalysisTK.jar -T HaplotypeCaller -R /home/share/user/user101/projects/yangshu/11.ref/ptr.fa -I $bam -L $now/$output_dir/$output_id/intervals.list -ERC GVCF -o $now/$output_dir/$output_id/$sample_id.vcf.gz -variant_index_type LINEAR -variant_index_parameter 128000\n";
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
		next if($bam=~/pro01-b/);
		$bam=~/([^\/]+)\.bam$/;
		my $sample_id=$1;
		print O "/home/share/software/java/jdk1.8.0_05/bin/java -jar /home/share/user/user101/software/GATK/GenomeAnalysisTK.jar -T HaplotypeCaller -R /home/share/user/user101/projects/yangshu/11.ref/ptr.fa -I $bam -L $now/$output_dir/$output_id/intervals.list -ERC GVCF -o $now/$output_dir/$output_id/$sample_id.vcf.gz -variant_index_type LINEAR -variant_index_parameter 128000\n";
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

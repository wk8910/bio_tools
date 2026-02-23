use warnings;
use strict;

my @vcf=<02.step2_combine/*.vcf.gz>;
my $out_dir="03.step3_hardfilter";
`mkdir $out_dir` if(!-e $out_dir);

my $ref = "/mnt/disk1/yanbiyao2016/02.bamfile/UMD3.1_chromosomes.fa";
open (OUT, "> $0.sh");
foreach my $vcf(@vcf){
	print "$vcf\n";
	$vcf=~/(\d+).vcf.gz/;
	my $order=$1;
	print OUT " /home/share/users/zhangxu2011/software/jre1.8.0_101/bin/java -jar /home/share/users/zhangxu2011/software/GenomeAnalysisTK.jar -T SelectVariants -R $ref -V $vcf -selectType SNP -o $out_dir/$1.raw_snp.vcf.gz\n";
print OUT " /home/share/users/zhangxu2011/software/jre1.8.0_101/bin/java -jar /home/share/users/zhangxu2011/software/GenomeAnalysisTK.jar -T SelectVariants -R $ref -V $vcf -selectType INDEL -o $out_dir/$1.raw_indel.vcf.gz\n";
print OUT " /home/share/users/zhangxu2011/software/jre1.8.0_101/bin/java -jar /home/share/users/zhangxu2011/software/GenomeAnalysisTK.jar -T VariantFiltration -R $ref -V $out_dir/$1.raw_snp.vcf.gz --filterExpression \"QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0\" --filterName \"my_snp_filter\" -o $out_dir/$1.filter_snp.vcf.gz\n";
}
close OUT;

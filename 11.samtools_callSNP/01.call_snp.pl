#! /usr/bin/env perl
use strict;
use warnings;

my $samtools="samtools";
my $bcftools="bcftools";
my $dict="/home/pool/users/wangkun2010/projects/wisent_me/00.ref/nc_ref.dict";
my $ref="/home/pool/users/wangkun2010/projects/wisent_me/00.ref/nc_ref.fa";
my $bam_list="bam.list";

my $out_dir="vcf_step1";
`mkdir $out_dir` if(!-e $out_dir);

open O,"> $0.sh";
open I,"< $dict";
while(<I>){
    chomp;
    next unless(/SN:(\S+)\s+LN:(\d+)/);
    my $id=$1;
    print O "$samtools mpileup -t DP -A -q 20 -Q 20 -uf $ref -r $id -b $bam_list | $bcftools call -mv | gzip - > $out_dir/$id.vcf.gz\n";
}
close I;
close O;

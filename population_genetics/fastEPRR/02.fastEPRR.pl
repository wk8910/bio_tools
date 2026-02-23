#! /usr/bin/env perl
use strict;
use warnings;

my $Rscript="/home/share/user/user101/bin/Rscript";

my @vcf=<vcf/*.vcf.gz>;
my $num=@vcf;

my $now=$ENV{'PWD'};

my $step1="step1";
my $step2="step2";
my $step3="step3";

`mkdir $step1` if(!-e $step1);
`mkdir $step2` if(!-e $step2);
`mkdir $step3` if(!-e $step3);

if(-e "$0.step1"){
    `rm -r $0.step1`;
}
if(-e "$0.step2"){
    `rm -r $0.step2`;
}
`mkdir $0.step1`;
`mkdir $0.step2`;
open(R1,"> $0.step1.sh");
open(R2,"> $0.step2.sh");
my $i=0;
foreach my $vcf(@vcf){
    $i++;
    $vcf=~/\/([^\/]+)\.vcf.gz/;
    my $chr=$1;
    open(O1,"> $0.step1/$chr.r");
    print O1 "library(FastEPRR)\nFastEPRR_VCF_step1(vcfFilePath=\"$now\/$vcf\",winLength=\"50\", winDXThreshold=30,srcOutputFilePath=\"$now/$step1/$chr\")\n";
    close O1;
    open(O2,"> $0.step2/$chr.r");
    print O2 "library(FastEPRR)\nFastEPRR_VCF_step2(srcFolderPath=\"$now/$step1/\",jobNumber=$num, currJob=$i, DXOutputFolderPath=\"$now/$step2\")\n";
    close O2;

    print R1 "$Rscript $now/$0.step1/$chr.r\n";
    print R2 "$/Rscript $now/$0.step2/$chr.r\n";
}
close R1;
close R2;

open(R3,"> $0.step3.Rscript");
print R3 "library(FastEPRR)\nFastEPRR_VCF_step3(srcFolderPath=\"$now/$step1\", DXFolderPath= \"$now/$step2\", finalOutputFolderPath=\"$now/$step3\")\n";
close R3;

open(O,"> $0.step3.sh");
print O "$Rscript $now/$0.step3.Rscript\n";
close O;

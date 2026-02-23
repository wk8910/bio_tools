#! /usr/bin/env perl
use strict;
use warnings;

my $dir="vcf";
my @vcf=<$dir/*.vcf>;
my $beagle="/home/share/user/user101/software/beagle/beagle.27Jul16.86a.jar";
my $java="/home/share/software/java/jdk1.8.0_05/bin/java";

open O,"> $0.sh";
foreach my $vcf(@vcf){
    print O "$java -jar $beagle gt=$vcf out=$vcf ibd=true impute=false ibdlod=10 nthreads=10\n";
}
close O;

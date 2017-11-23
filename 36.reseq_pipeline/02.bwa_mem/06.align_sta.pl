#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my @bam=<01.bamBySample/*.bam>;
my $outdir="10.align_sta";
`mkdir $outdir` if(!-e $outdir);

open(O,"> $0.sh");
foreach my $bam(@bam){
    $bam=~/([^\/]+)\.bam$/;
    my $name=$1;
    print O "perl $now/align_statistics.pl $now/$bam $now/$outdir/$name\n";
}
close O;

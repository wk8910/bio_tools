#! /usr/bin/env perl
use strict;
use warnings;

my $bamdir="bam";
my $outdir="count";
`mkdir $outdir` if(!-e $outdir);
my @bam=<$bamdir/*.bam>;
my $bed="regions.bed";
my $tool="scripts/sam2reads_count.pl";

open O,"> $0.sh";
foreach my $bam(@bam){
    $bam=~/([^\/]+)$/;
    my $file=$1;
    print O "samtools view -L $bed $bam | perl $tool > $outdir/$file.count\n";
}
close O;

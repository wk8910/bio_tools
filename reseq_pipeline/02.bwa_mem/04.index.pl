#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my @bam=<02.bamRmdup/*.bam>;

open(O,"> $0.sh");
foreach my $bam(@bam){
    print O "/home/share/user/user101/bin/samtools index $now/$bam\n";
}
close O;

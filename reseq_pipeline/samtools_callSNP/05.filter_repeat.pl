#! /usr/bin/env perl
use strict;
use warnings;

my $vcf="04.merge.pl.vcf.gz";
my $bed="keep.bed";
my $bgzip="bgzip";
my $tabix="tabix";

open O,"> $0.sh";
print O "$tabix -p vcf $vcf\n$tabix -hR $bed $vcf | $bgzip -c > $0.vcf.gz";
close O;

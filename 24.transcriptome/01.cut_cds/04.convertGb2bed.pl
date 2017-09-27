#! /usr/bin/env perl
use strict;
use warnings;

my $indir="clusters";
my $tool1="scripts/convertHTM.pl";
my $tool2="scripts/extractBed.pl";

my @htm=<$indir/*.htm>;
open O,"> $0.sh";
foreach my $htm(@htm){
    $htm=~/(.*)-gb.htm$/;
    my $fa=$1;
    print O "perl $tool1 $htm > $htm.info; perl $tool2 $htm.info $fa > $fa.bed\n";
}
close O;

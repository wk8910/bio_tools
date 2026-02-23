#! /usr/bin/env perl
use strict;
use warnings;

my @psl=<psl_by_species/*.raw.psl>;

open O,"> $0.sh";
foreach my $psl(@psl){
    print O "perl sub.group_by_species.pl $psl\n";
}
close O;

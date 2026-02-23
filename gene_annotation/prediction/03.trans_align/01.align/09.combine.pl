#! /usr/bin/env perl
use strict;
use warnings;

my $dir="psl_by_species";
my @psl=<$dir/*.group.psl>;

open O,"> $0.psl";
foreach my $psl(@psl){
    open I,"< $psl";
    while (<I>) {
        chomp;
        next if(/^#/);
        print O "$_\n";
    }
    close I;
}
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $dir="bootstrap";

my @file=<$dir/*/all.tre.tre>;

foreach my $file(@file){
    `perl convertNEXUS2newick.pl $file`;
}

`cat $dir/*/all.tre.tre.nwk > bootstrap.tre`;

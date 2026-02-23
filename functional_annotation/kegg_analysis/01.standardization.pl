#! /usr/bin/env perl
use strict;
use warnings;

my $map_file="map.html";
my $out_prefix="kegg";

open(I,"< $map_file");
open(O,"> $out_prefix.map");
while (<I>) {
    chomp;
    next unless(/<p class='trd'>/);
    #print "$_\n";
    /(ko\d+)/;
    my $ko=$1;
    /([^<>]+)\(\d+\)<\/p>$/;
    my $info=$1;
    print O "$ko;$info;";
    my @line;
    while (/(\/K\d+)/g) {
        my $kn=$1;
        $kn=~s/\///;
        push @line,$kn;
    }
    print O join "\t",@line,"\n";
}
close I;
close O;

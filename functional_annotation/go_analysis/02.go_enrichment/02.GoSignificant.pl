#! /usr/bin/env perl
use strict;
use warnings;

my $dir="compare_tetrapod.lst.result";
my @result=<$dir/*.goEnrichment>;

foreach my $result(@result){
    my $in=$result;
    my $sig="$result.sig";

    open I,"< $in";
    open U,"> $sig";;
    my $head=<I>;
    print U "$head";
    while (<I>) {
        chomp;
        my @a=split(/\t/);
        next unless($a[7]>0);
        if($a[11]<0.05 || $a[12]<0.05 || $a[13]<0.05){
            print U "$_\n";
        }
    }
    close U;
    close I;
}

#! /usr/bin/env perl
use strict;
use warnings;

my $htm=shift;

# Flanks: [283  297]  [1243  1896]
open I,"< $htm";
while (<I>) {
    chomp;
    next unless(/^Flanks/);

    my @a=split(/\[/);
    for(my $i=1;$i<@a;$i++){

        $a[$i]=~s/\]//g;
        $a[$i]=~/(\d+)\s+(\d+)/;
        my ($left,$right)=($1,$2);
        print "$left\t$right\n";
    }
}
close I;

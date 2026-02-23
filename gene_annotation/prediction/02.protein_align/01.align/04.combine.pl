#! /usr/bin/env perl
use strict;
use warnings;

my $dir="alignment";
my @psl=<$dir/*/*.psl>;

open O,"> $0.psl";
foreach my $psl(@psl){
    open I,"< $psl";
    for(my $i=0;$i<5;$i++){
        <I>;
    }
    while (<I>) {
        chomp;
        print O "$_\n";
    }
    close I;
}
close O;

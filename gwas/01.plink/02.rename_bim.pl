#! /usr/bin/env perl
use strict;
use warnings;

my $in="plink.bim.old";
my $out="plink.bim";

open O,"> $out";
open I,"< $in";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    $a[1]=$a[0]."-".$a[3];
    my $line=join "\t",@a;
    print O "$line\n";
}
close I;
close O;

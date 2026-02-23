#! /usr/bin/env perl
use strict;
use warnings;

my $l1=shift;
my $l2=shift;

my %hash;
open I,"< $l1";
<I>;
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    $hash{$a[0]}++;
}
close I;

open I,"< $l2";
<I>;
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    $hash{$a[0]}++;
}
close I;

foreach my $a(sort keys %hash){
    if($hash{$a}>1){
        print "$a\n";
    }
}

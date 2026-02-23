#! /usr/bin/env perl
use strict;
use warnings;

my $table="sqltable.ds-ss";
my $out="$0.out";

my %hash;
my %species;
open I,"< $table";
while (<I>) {
    chomp;
    next unless(/100%/);
    my @a=split(/\s+/);
    $hash{$a[0]}{count}++;
    $hash{$a[0]}{$a[2]}=$a[4];
    $species{$a[2]}++;
}
close I;

my @species=sort keys %species;
my $pop1=$species[0];
my $pop2=$species[1];

open O,"> $out";
foreach my $group(sort keys %hash){
    next unless($hash{$group}{count}==2);
    next unless(exists $hash{$group}{$pop1} && exists $hash{$group}{$pop2});
    print O "$hash{$group}{$pop1}\t$hash{$group}{$pop2}\n";
}
close O;

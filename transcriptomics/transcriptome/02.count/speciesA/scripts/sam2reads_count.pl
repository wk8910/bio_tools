#! /usr/bin/env perl
use strict;
use warnings;

my %hash;
my $control=0;
while(<>){
    chomp;
    my @a=split(/\s+/);
    my $flag=$a[1];
    next if($flag>256);
    next if($flag & 4);    my $id=$a[2];
    $hash{$id}++;
    # last if($control++>1000);
}

foreach my $id(sort {$hash{$b} <=> $hash{$a}} keys %hash){
    print "$id\t$hash{$id}\n";
}

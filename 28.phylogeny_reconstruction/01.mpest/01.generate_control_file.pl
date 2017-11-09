#! /usr/bin/env perl
use strict;
use warnings;

# my $all_tree="all.gene_tree";
my $all_tree=shift;
# my $out="control_file";

open I,"< $all_tree";
my %name;
my $count=0;
while(<I>){
    chomp;
    while(/([^(),]+):/g){
        my $id=$1;
        next if(length($id) == 0);
        $name{$id}=1;
    }
    $count++;
}
close I;
my $species_number=keys %name;

# open O,"> $out";
print "$all_tree\n0\n3141592653589793\n20\n$count\t$species_number\n";
foreach my $id(sort keys %name){
    print "$id\t1\t$id\n";
}
print "0\n";
# close O;

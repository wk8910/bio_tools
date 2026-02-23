#! /usr/bin/env perl
use strict;
use warnings;

my $psl="10.final_group.pl.psl";
my $out="$0.out";

my %hash;
my %white;
my $group_id="NA";
open I,"< $psl";
while (<I>) {
    chomp;
    if(/^##/){
        /##\s+(\S+)/;
        $group_id=$1;
    }
    else {
        my @a=split(/\s+/);
        $a[9]=~/^([^_]+)/;
        my $species=$1;
        $white{$group_id}{$species}=1;
    }
    $hash{$group_id}.="$_\n";
}
close I;

open O,"> $out";
foreach my $group_id(sort {$a<=>$b} keys %white){
    my $num=keys %{$white{$group_id}};
    if($num>=2){
        print O "$hash{$group_id}";
    }
}
close O;

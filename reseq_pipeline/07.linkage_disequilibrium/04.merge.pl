#! /usr/bin/env perl
use strict;
use warnings;

my @decay=<*.decay.sta>;
my $out="$0.txt";

open O,"> $out";
print O "pop\tdis\tr2\n";
foreach my $decay(@decay){
    open I,"< $decay";
    <I>;
    $decay=~/([_\w]+)[^\/]*$/;
    my $id=$1;
    print "$id\n";
    while(<I>){
	chomp;
	my @a=split(/\s+/);
	my ($dis,$r2)=@a;
	print O "$id\t$dis\t$r2\n";
    }
    close I;
}
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $dict="cattle.dict";
my $list_dir="chr";
my $tool="scripts/generate_reference_v2.pl";
my %hash;
open O,"> $0.sh";
open I,"< $dict";
while (<I>) {
    chomp;
    next unless(/SN:(\S+)\s+LN:(\d+)/);
    my ($chr,$len)=($1,$2);
    if(!-e "$list_dir/$chr.lst.gz"){
        print STDERR "$list_dir/$chr.lst.gz cannot found!\n";
        next;
    }
    print O "perl $tool $list_dir/$chr.fa $list_dir/$chr.lst.gz bison $chr $len\n";
}
close I;
close O;

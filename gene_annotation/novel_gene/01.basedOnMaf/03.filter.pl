#! /usr/bin/env perl
use strict;
use warnings;

my $dir="novel_genes";

my @list=<$dir/*.novel_gene>;

foreach my $list(@list){
    open I,"$list";
    my $out="$list.clean.lst";
    open O,"> $out";
    while (<I>) {
        chomp;
        my @a=split(/\s+/);
        my $percent=$a[2]/$a[1];
        if($percent>=0.3){
            print O "$_\n";
        }
    }
    close O;
    close I;
}

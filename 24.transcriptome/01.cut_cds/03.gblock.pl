#! /usr/bin/env perl
use strict;
use warnings;

my $indir="clusters";
my $gblocks="/home/share/users/wangkun2010/software/gblocks/Gblocks_0.91b/Gblocks";

my @aln=<$indir/*.aln>;

open O,"> $0.sh";
foreach my $aln(@aln){
    print O "$gblocks $aln -t=d -b5=n\n";
}
close O;

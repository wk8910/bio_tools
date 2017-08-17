#! /usr/bin/env perl
use strict;
use warnings;

my $file=shift;
open I,"perl ~/bio_tools/00.scripts/read_fasta.pl $file |";
while (my $id=<I>) {
    chomp $id;
    my $seq=<I>;
    chomp $seq;
    my $len=length($seq);
    $seq=~s/[Nn]//g;
    my $e_len=length($seq);
    print "$id\t$len\t$e_len\n";
}
close I;

#! /usr/bin/env perl
use strict;
use warnings;
use FileHandle;

my $psl="06.convert.pl.psl";
my $outdir="psl_by_species";
`mkdir $outdir` if(!-e $outdir);
my %fh;
open I,"< $psl";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    $a[9]=~/^([^\|]+)/;
    my $species=$1;
    if(!exists $fh{$species}){
        open $fh{$species},"> $outdir/$species.raw.psl";
    }
    $fh{$species}->print("$_\n");
}
close I;

foreach my $species(keys %fh){
    close $fh{$species};
}

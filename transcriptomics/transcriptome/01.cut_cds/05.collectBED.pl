#! /usr/bin/env perl
use strict;
use warnings;
use FileHandle;

my $indir="clusters";
my @bed=<$indir/*.bed>;
my $outdir="bed";
`mkdir $outdir` if(!-e $outdir);

my %fh;
foreach my $bed(@bed){
    open I,"< $bed";
    while (<I>) {
        chomp;
        /^([^\|]+)\|(.*)/;
        my ($species,$content)=($1,$2);
        if(!exists $fh{$species}){
            open $fh{$species},"> $outdir/$species.bed";
        }
        $fh{$species}->print("$content\n");
    }
    close I;
}
foreach my $species(keys %fh){
    close $fh{$species};
}

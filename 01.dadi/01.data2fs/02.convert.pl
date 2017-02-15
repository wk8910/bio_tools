#! /usr/bin/env perl
use strict;
use warnings;

my $indir="01.split_data";
my $outdir="02.convert_fs";

`mkdir $outdir` if(!-e $outdir);
my @data=<$indir/*.data>;
open O,"> $0.sh";
foreach my $data(@data){
    $data=~/([^\/]+)\.data$/;
    my $id=$1;
    print O "python convert.py $data $outdir/$id.fs\n";
}
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $dir="bootstrap";
my $now=$ENV{'PWD'};
my $model="run_model.py";

my @fs=<$now/$dir/*/dadi.fs>;
open(O,"> $0.sh");
foreach my $fs(@fs){
    $fs=~/(.*)\/dadi.fs$/;
    my $subdir=$1;
    my $outdir="$subdir/output_dadi";
    `mkdir $outdir` if(!-e $outdir);
    for(my $i=1;$i<=50;$i++){
	print O "python $now/$model $subdir/dadi.fs > $outdir/output.$i.txt\n";
    }
}
close O;

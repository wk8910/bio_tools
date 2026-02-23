#! /usr/bin/env perl
use strict;
use warnings;

my $outdir="output_dadi";
`mkdir $outdir` if(!-e $outdir);

my $now=$ENV{'PWD'};

open(O,"> $0.sh");
for(my $i=1;$i<=10000;$i++){
    print O "python2 $now/01.model.py $now/dadi.fs > $now/$outdir/output.$i.txt\n";
}
close O;

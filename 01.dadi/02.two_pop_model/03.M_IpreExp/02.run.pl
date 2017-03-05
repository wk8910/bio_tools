#! /usr/bin/env perl
use strict;
use warnings;

my $outdir="01.output";
`mkdir $outdir` if(!-e $outdir);

my $now=$ENV{'PWD'};

open(O,"> $0.sh");
for(my $i=1;$i<=1000;$i++){
    print O "export PATH=/home-gk/users/nscc1500/software/python/ActivePython-2.7.10.12-linux-x86_64-build/bin:\$PATH:/home-gk/users/nscc1500/software/dadi-build/lib64/python2.6/site-packages; $now/01.model.py $now/dadi.fs > $now/$outdir/output.$i.txt\n";
}
close O;

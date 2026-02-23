#! /usr/bin/env perl
use strict;
use warnings;

my $fsc="/public/home/wangkun/software/fastsimcoal/fsc26_linux64/fsc26";

my $dir=$ENV{'PWD'};
`mkdir $dir/replicates` if(!-e "$dir/replicates");
open(O,"> $0.sh");
for(my $i=1;$i<=30;$i++){
    my $cmd="$fsc -t model.tpl -n100000 -N100000 -m -e model.est -M 1e-5 -w 1e-5 -l 10 -L 40 -c 0 -q";
    my $tmpdir="$dir/replicates/run$i";
    `mkdir $tmpdir` if(!-e $tmpdir);
    `cp *.obs $tmpdir; cp model.tpl model.est $tmpdir;`;
    print O "cd $tmpdir; $cmd\n";
}

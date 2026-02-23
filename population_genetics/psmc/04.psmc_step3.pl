#! /usr/bin/env perl
use strict;
use warnings;

my $out="$0.sh";
my $outdir="psmc_files";
`mkdir $outdir` if(!-e $outdir);
open(O,"> $out");
print O "/home/share/user/user101/software/PSMC/psmc/psmc -N25 -t15 -r5 -p \"4+25*2+4+6\" -o $outdir/diploid.psmc diploid.psmcfa\n";
for(my $i=1;$i<=100;$i++){
    print O "/home/share/user/user101/software/PSMC/psmc/psmc -N25 -t15 -r5 -b -p \"4+25*2+4+6\" -o $outdir/round-$i.psmc split.fa\n";
}
close O;

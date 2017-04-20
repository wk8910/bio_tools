#! /usr/bin/env perl
use strict;
use warnings;

my $selscan="/home/share/user/user101/software/selscan/selscan/bin/linux/selscan";
my $indir="chr";
my $outdir="ihs";
`mkdir $outdir` if(!-e $outdir);

my @hap=<$indir/*.hap>;

open O,"> $0.sh";
foreach my $hap(@hap){
    my $map=$hap;
    $map=~s/.hap$/.map/;
    $hap=~/([^\/]+).hap/;
    my $id=$1;
    print O "$selscan --ihs --hap $hap --map $map --out $outdir/$id.txt\n";
}
close O;

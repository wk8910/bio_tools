#! /usr/bin/env perl
use strict;
use warnings;

my $indir="genes";
my $clustalw2="/home/share/software/ClustalW/clustalw-2.1-linux-x86_64-libcppstatic/clustalw2";
my $raxml="/home/share/users/wangkun2010/software/RaxML/standard-RAxML-8.2.10/raxmlHPC-PTHREADS";
my $now=$ENV{'PWD'};

my @fa=<$indir/*.fa>;

open O,"> $0.sh";
foreach my $fa(@fa){
    # print O "cd $dir; $clustalw2 -INFILE=align.fa -CONVERT -OUTFILE=align.phy -OUTPUT=PHYLIP; $raxml -s align.phy -n align.phb -f a -m GTRGAMMAI -k -x 271828 -N 100 -p 31415 -o bbu01,buffalo001,buffalo002,buffalo003; cd $now\n";
    $fa=~/([^\/]+).fa$/;
    my $id=$1;
    print O "cd $indir; $clustalw2 -INFILE=$id.fa -CONVERT -OUTFILE=$id.align.phy -OUTPUT=PHYLIP; $raxml -T 2 -f a -s $id.align.phy -n $id.align.phb -m GTRGAMMAI -x 271828 -N 100 -p 31415 -o buffalo; cd $now\n";
}
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $indir="output";
my $fasttree="/home/share/users/wangkun2010/software/fasttree/FastTreeMP";
my $clustalw2="/home/share/software/ClustalW/clustalw-2.1-linux-x86_64-libcppstatic/clustalw2";
my $raxml="/home/share/users/wangkun2010/software/RaxML/standard-RAxML-8.2.10/raxmlHPC-PTHREADS";
my $now=$ENV{'PWD'};

my @dir=<$indir/*>;

open O,"> $0.sh";
foreach my $dir(@dir){
    if(-d "$dir"){
        # print O "cd $dir; $clustalw2 -INFILE=align.fa -CONVERT -OUTFILE=align.phy -OUTPUT=PHYLIP; $raxml -s align.phy -n align.phb -f a -m GTRGAMMAI -k -x 271828 -N 100 -p 31415 -o bbu01,buffalo001,buffalo002,buffalo003; cd $now\n";
        # print O "cd $dir; $clustalw2 -INFILE=align.fa -CONVERT -OUTFILE=align.phy -OUTPUT=PHYLIP; $raxml -T 2 -s align.phy -n align.phb -m GTRGAMMAI -p 31415 -o bbu01,buffalo001,buffalo002,buffalo003; cd $now\n";
        print O "$fasttree -nt $dir/align.fa > $dir/fastree.tre\n";
    }
}
close O;

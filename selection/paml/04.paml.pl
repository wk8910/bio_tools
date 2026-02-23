use strict;
use warnings;

## created by Yongzhi Yang. 2017/3/20 ##
my $indir="genes";

open O,"> $0.sh";
my @in=<$indir/*/cds.paml>;
my @ctl=<ctl/*ctl>;
for my $ctl (@ctl){
    for my $in (@in){
        $in=~/^(\S+)\/cds.paml/;
        print O "cd $1 ; /home/share/users/wangkun2010/software/paml/paml4.9e/src/codeml ../../$ctl > /dev/null ; cd ../../\n";
    }
}
close O;

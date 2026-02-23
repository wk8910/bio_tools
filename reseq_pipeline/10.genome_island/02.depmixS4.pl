#! /usr/bin/env perl
use strict;
use warnings;

my $file="01.merge.pl.txt";
my $rscript="/home/share/user/user101/software/R/R-3.2.2-build/bin/Rscript";
# my $file=shift;

open I,"< $file";
my $head=<I>;
my @seq;
my $control=-1;
my $chr_pre="NA";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my $chr=$a[0];
    if($chr ne $chr_pre){
	$control++;
    }
    $seq[$control]++;
    $chr_pre = $chr;
}
close I;

# print "$seq[0]\n";

my $line=join ",",@seq;

open R,"> $0.Rscript";
print R "library('depmixS4')
data=read.table('$file',header=T)
set.seed(31415)
mod = depmix(list(fst~1),ns=3,family=list(gaussian()),data=data,ntimes=c($line))
fm <- fit(mod)
info=summary(fm)
write.table(info,file=\"divergenceIsland.info\",quote=F)
a=posterior(fm)
write.table(a,file=\"divergenceIsland.txt\",quote=F)";
close R;

`$rscript $0.Rscript 2>&1 > $0.Rscript.log`;

#! /usr/bin/env perl
use strict;
use warnings;

my $kin="snp.kin0";
my $output="king4ggplot2.txt";
my $rscript_bin="/home/share/user/user101/software/R/R-3.2.2-build/bin/Rscript";

open(I,"< $kin");
open(O,"> $output");
while(<I>){
    chomp;
    my @a=split(/\s+/);
    if($a[-1]=~/Kinship/){

    }
    elsif($a[-1] > 0.354){
	$a[-1]=4; # duplicate
    }
    elsif($a[-1] > 0.177){
	$a[-1]=3; # 1st-degree
    }
    elsif($a[-1] > 0.0884){
	$a[-1]=2; # 2st-degree
    }
    elsif($a[-1] > 0.0442){
	$a[-1]=1; # 3st-degree
    }
    else{
	$a[-1]=0; # independent
    }
    print O join "\t",@a,"\n";
}
close I;
close O;

open(R,"> $0.r");
print R "
library('ggplot2');
a=read.table('$output',header=T);
pdf('$0.pdf');
ggplot(a,aes(ID1,ID2,fill=Kinship))+geom_tile()+theme(axis.text.x = element_text(angle = 90, hjust = 1))+scale_fill_gradient(low=\"white\",high=\"steelblue\");
dev.off();
";
close R;

`$rscript_bin $0.r`;

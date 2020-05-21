#! /usr/bin/env perl
use strict;
use warnings;

# this script is intended to find the window with significant more number of extraordinary_site

my $input="pade.positive.test";
my $out="$0.window.out";
my $extraordinary_site="0.01"; # the top 1% sites will be treated as extraordinary sites
my $window_size=10000; # the length of non-overlap windows for further testing

my %hash;
open I,"< $input"; # the input file has four column, the chromosome name, the position of sites, the tested score, the z-transformed tested score
<I>; # the first line will be treated as head line and be discarded
my @zscore;
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($chr,$pos,$score,$zscore)=@a;
    $hash{$chr}{$pos}{score}=$score;
    $hash{$chr}{$pos}{zscore}=$zscore;
    push @zscore,$zscore;
}
close I;

@zscore=sort {$a<=>$b} @zscore;
my $num=@zscore;
my $criteria=$zscore[int((1-$extraordinary_site)*$num+0.5)];

print STDERR "A total of $num sites loaded, the top $extraordinary_site sites has a zscore larger than $criteria\n";

my %count;
my ($total_count,$total_selected)=(0,0);
foreach my $chr(sort keys %hash){
    foreach my $pos(sort keys %{$hash{$chr}}){
        my $zscore=$hash{$chr}{$pos}{zscore};
        my $window=int($pos/$window_size)*$window_size;
        $count{$chr}{$window}{num}++;
        $total_count++;
        if($zscore >= $criteria){
            $count{$chr}{$window}{selected}++;
            $total_selected++;
        }
    }
}

open O,"> $0.out";
print O "chr\twindow\tnum\tselected\n";
foreach my $chr(sort keys %count){
    foreach my $window(sort {$a<=>$b} keys %{$count{$chr}}){
        my $num=$count{$chr}{$window}{num};
        my $selected=0;
        if(exists $count{$chr}{$window}{selected}){
            $selected=$count{$chr}{$window}{selected};
        }
        print O "$chr\t$window\t$num\t$selected\n";
    }
}
close O;

open R,"> $0.R";
print R '
a=read.table("01.window_scan.pl.out",header=T);
pvalue=c(rep(1,nrow(a)));
prior='.$total_selected.'/'.$total_count.';
for(i in 1:nrow(a)){pvalue[i]=binom.test(a$selected[i],a$num[i],p=prior,alternative="greater")$p.value};
qvalue=p.adjust(pvalue,method="fdr");
a$pvalue=pvalue;
a$qvalue=qvalue;
write.table(a,file="01.window_scan.pl.out",quote=F,row.names=F,sep="\t");
b=subset(a,a$qvalue<0.05);
write.table(b,file="01.window_scan.pl.out.sig",quote=F,row.names=F,sep="\t");
';
close R;

print "Please run:\nRscript $0.R\n";

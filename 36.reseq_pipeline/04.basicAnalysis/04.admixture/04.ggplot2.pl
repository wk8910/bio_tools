#! /usr/bin/env perl
use strict;
use warnings;

my @result=<*.Q>;
my $fam="../plink.fam";

my @ind;
open I,"< $fam";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    push @ind,$a[0];
}

open R,"> $0.R";
print R "library(\"ggplot2\");\npdf(file=\"$0.pdf\",width=10,height=3)\n";
foreach my $file(@result){
    my $out="$file.input";
    open O,"> $out";
    open I,"< $file";
    my $control=0;
    print O "id\tpercent\ttype\n";
    while(<I>){
	chomp;
	my @a=split(/\s+/);
	for(my $i=0;$i<@a;$i++){
	    print O "$ind[$control]\t$a[$i]\t$i\n";
	}
	$control++;
    }
    close O;
    close I;
    print R "a=read.table('$out',header=T);
ggplot(a,aes(id,percent,fill=factor(type)))+geom_bar(stat='identity')+ theme_classic()+theme(axis.text.x = element_text(angle = 270, hjust = 1))\n";
}
print R "dev.off()\n";
close R;

print "/home/share/user/user101/software/R/R-3.2.2-build/bin/Rscript $0.R\n";

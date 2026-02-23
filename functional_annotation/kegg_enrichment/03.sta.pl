#! /usr/bin/env perl
use strict;
use warnings;

my ($target,$background,$out)=@ARGV;
my $rscript="Rscript";
my $min_ko=5; # min number of genes requred in a reported ko
die "Usage: $0 <target list> <background list> <output file prefix>\n" if(@ARGV<3);
$out="$out.koEnrichment";

my @genename;
open I,"< $background";
while (<I>) {
    chomp;
    /(\S+)$/;
    push @genename,$1;
}
close I;

my %hash;
open I,"< $target";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($geneid)=@a;
    $hash{$geneid}++;
}
close I;
my $background_number=@genename;
my $target_number= keys %hash;

my %kegg;
my %info;
open I,"< gene.path";
while (<I>) {
    chomp;
    my ($geneid,$ko,$info)=split(/\t/);
    $kegg{$ko}{$geneid}=1;
    $info{$ko}=$info;
}
close I;

my $number=0;
open O,"> $out";
print O "ko\tbackground\ttarget\tko\toverlap\tpvalue\tinfo\n";
foreach my $ko(sort keys %kegg){
    my %selected;
    my $ko_number=keys %{$kegg{$ko}};
    next if($ko_number<$min_ko);
    $number++;
    foreach my $geneid(keys %{$kegg{$ko}}){
        if(exists $hash{$geneid}){
            $selected{$geneid}++;
        }
    }
    my $overlap=keys %selected;
    my $percent1 = $overlap/$target_number;
    my $percent2 = $ko_number/$background_number;
    my $p=&hyper($background_number,$target_number,$ko_number,$overlap);
    my $info=$info{$ko};
    print O "$ko\t$background_number\t$target_number\t$ko_number\t$overlap\t$p\t$info\n";
}
close O;

open O,"> $out.rscript";
print O 'a=read.table("'.$out.'",sep="\t",header=T)
# a$fdr=p.adjust(a$pvalue,method="fdr")
for(i in 1:length(a$pvalue))
{
    a$fdr[i]=p.adjust(a$pvalue[i],method="fdr",n='.$number.')
}
write.table(a,file="'."$out.fdr".'",quote=F,row.names=F,sep="\t")
';
close O;
`$rscript $out.rscript`;

sub hyper{
    my ($m,$t,$n,$r)=@_;
    my $var = 1;
    for(1..$n){
        $var *= ($m-$t-$n+$_)/($m-$n+$_);
    }
    my $P_value = 1 - $var;
    for(my $x=1;$x<=$r-1;$x++){
        $var *= ($t-$x+1)*($n-$x+1)/$x/($m-$t-$n+$x);
        $P_value -= $var;
    }
    if($P_value < 0){
        return 0;
    }
    return $P_value;
}

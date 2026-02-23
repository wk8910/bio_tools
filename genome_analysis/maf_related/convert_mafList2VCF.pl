#! /usr/bin/env perl
use strict;
use warnings;

my $list="bovine.sixSpecies.maf.lst.gz";
my $outfile="maf.vcf.gz";

if($list=~/gz$/){
    open I,"zcat $list |";
}
else {
    open I,"< $list";
}
my $head=<I>;
chomp $head;
my @name=split(/\s+/,$head);

my @head=("#CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO","FORMAT");
for(my $i=2;$i<@name;$i++){
    push @head,$name[$i];
}

my %seq;
my $control=0;
my $code="NA";
open O,"| gzip - > $outfile";
my $vcf_head=join "\t",@head;
print O "$vcf_head\n";
while(<I>){
    my @a=split(/\s+/);
    my $chr=$a[0];
    # next if($chr=~/X|Y/);
    my $pos=$a[1];
    my %base;
    for(my $i=2;$i<@a;$i++){
        $a[$i]=uc($a[$i]);
        if($a[$i]=~/W/){
            $a[$i]="A";
            $a[$i]="T" if(rand(1)<0.5);
        }
        elsif($a[$i]=~/S/){
            $a[$i]="C";
            $a[$i]="G" if(rand(1)<0.5);
        }
        elsif($a[$i]=~/M/){
            $a[$i]="A";
            $a[$i]="C" if(rand(1)<0.5);
        }
        elsif($a[$i]=~/K/){
            $a[$i]="G";
            $a[$i]="T" if(rand(1)<0.5);
        }
        elsif($a[$i]=~/R/){
            $a[$i]="A";
            $a[$i]="G" if(rand(1)<0.5);
        }
        elsif($a[$i]=~/Y/){
            $a[$i]="C";
            $a[$i]="T" if(rand(1)<0.5);
        }
        next if($a[$i]!~/[ATCG]/);
        $base{$a[$i]}++;
    }
    my $num=keys %base;
    my @base=sort {$base{$b}<=>$base{$a}} keys %base;
    next if($num > 2);
    my $alt="-";
    if($num==2){
        $alt=$base[1];
    }
    my @line=($chr,$pos,".",$base[0],$alt,100,".",".","GT");
    for(my $i=2;$i<@a;$i++){
        my $id=$name[$i];
        my $base=$a[$i];
        if($base!~/[ATCG]/){
            push @line,"./.";
        }
        elsif($base eq $base[0]){
            push @line,"0/0";
        }
        else{
            push @line,"1/1";
        }
    }
    my $line = join "\t",@line;
    print O "$line\n";
    last if($control++>=10000);
}
close I;
close O;

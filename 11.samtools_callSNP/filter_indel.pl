#! /usr/bin/env perl
use strict;
use warnings;

my $vcf=shift;
my $out=shift;

open I,"zcat $vcf |";
my %indel;
while(<I>){
    next if(/^#/);
    my @a=split(/\s+/);
    my ($chr,$pos,$id,$ref,$alt)=@a;
    my @var=split(/,/,$alt);
    push @var,$ref;
    my $indel_test=0;
    foreach my $var(@var){
        my $len=length($var);
        if($len>1){
            $indel_test=1;
            last;
        }
    }
    my $len=length($ref)-1;
    if($indel_test == 1){
        for(my $i=$pos-5;$i<=$pos+$len+5;$i++){
            $indel{$chr}{$i}=1;
        }
    }
}
close I;

open O,"| gzip - > $out";
open I,"zcat $vcf |";
while (<I>) {
    chomp;
    if(/^#/){
        print O "$_\n";
    }
    else{
        my @a=split(/\s+/);
        my ($chr,$pos,$id,$ref,$alt)=@a;
        next if(exists $indel{$chr}{$pos});
        print O "$_\n";
    }
}
close I;
close O;

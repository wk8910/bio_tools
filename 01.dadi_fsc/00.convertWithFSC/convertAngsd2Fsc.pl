#! /usr/bin/env perl
use strict;
use warnings;

my $file=shift;
my $pop1_num=shift;

die "Usage: $0 <angsd file> <ind number of pop1>" if(!-e $file || !$pop1_num);

open(I,"< $file");
open(O,"> model_jointDAFpop1_0.obs");
my @data;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    for(my $i=0;$i<@a;$i++){
        $data[$i]+=$a[$i];
    }
}
close I;

my $control=0;
my @line=();
print O "1 observation\n";
my @first_line=("");
for(my $i=0;$i<=$pop1_num*2;$i++){
    my $x="d0_".$i;
    push @first_line,$x;
}
print O join "\t",@first_line,"\n";
my $j=0;
for(my $i=0;$i<@data;$i++){
    push @line,$data[$i];
    $control++;
    if($control==($pop1_num*2+1)){
        my $y="d1_".$j;
        print O "$y\t";
        print O join "\t",@line,"\n";
        @line=();
        $control=0;
        $j++;
    }
}
close O;

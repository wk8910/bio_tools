#! /usr/bin/env perl
use strict;
use warnings;

my $info="divergenceIsland.info";
my $fst="01.merge.pl.txt";
my $island="divergenceIsland.txt";
my $out="$0.txt";

my %state;
open I,"< $info";
<I>;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($state,$mean,$sd)=@a;
    $state=~s/St//;
    $state{$state}{mean}=$mean;
}
close I;

my @stat=("1.low","2.mid","3.high");
my $stat=0;
foreach my $state(sort {$state{$a}{mean} <=> $state{$b}{mean}} keys %state){
    $state{$state}{stat}=$stat[$stat];
    $stat++;
}

open O,"> $out";
open I1,"< $fst";
open I2,"< $island";
<I1>;
<I2>;
print O "chr\tpos\tfst\tstat\n";
while(my $l1=<I1>){
    my $l2=<I2>;
    chomp $l1;
    chomp $l2;
    my @l1=split(/\s+/,$l1);
    my @l2=split(/\s+/,$l2);
    my $state=$l2[1];
    my $stat=$state{$state}{stat};
    push @l1,$stat;
    print O join "\t",@l1,"\n";
}
close O;
close I1;
close I2;

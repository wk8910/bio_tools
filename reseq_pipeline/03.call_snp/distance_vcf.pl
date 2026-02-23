#! /usr/bin/env perl
use strict;
use warnings;

my $vcf=shift;
my @ind=("bbo006","bta01","bbi01");
my $window_size=500000;

open I,"zcat $vcf |";
my @head;
my %result;
my %info;
my $control=0;
# open O,"> debug.txt";
while (<I>) {
    chomp;
    next if(/^##/);
    my @a=split(/\s+/);
    if(/^#/){
        @head=@a;
        next;
    }
    my %hash;
    my %test;
    my ($chr,$pos)=($a[0],$a[1]);
    my $window=int($pos/$window_size)*$window_size;
    for (my $i=9;$i<@a;$i++) {
        my $id=$head[$i];
        $a[$i]=~/^(.)\/(.)/;
        my ($left,$right)=($1,$2);
        # next if($dp<2);
        next if($left eq ".");
        my $value=$left+$right;
        $hash{$id}=$value;
        $test{$id}=$a[$i];
    }
    my $light=1;
    foreach my $ind(@ind){
        if(!exists $hash{$ind}){
            $light=0;
        }
    }
    next if($light==0);
    $info{$chr}{$window}++;
    # print O "$chr\t$pos\t$window\t";
    for (my $i=0;$i<@ind;$i++){
        # print O "$ind[$i]:$hash{$ind[$i]}:$test{$ind[$i]}\t";
        for(my $j=$i+1;$j<@ind;$j++){
            my $a=$hash{$ind[$i]};
            my $b=$hash{$ind[$j]};
            my $dis=abs($a-$b)/2;
            my $type=$ind[$i]."_".$ind[$j];
            $result{$chr}{$window}{$type}+=$dis;
            # print STDERR "$chr\t$window\t$type\t$dis\n";
        }
    }
    # print O "\n";
    # last if($control++>100000);
}
close I;
# close O;

my @newhead=("chr","window","informative_site");
for(my $i=0;$i<@ind;$i++){
    for(my $j=$i+1;$j<@ind;$j++){
        my $type=$ind[$i]."_".$ind[$j];
        push @newhead,$type;
    }
}
print join "\t",@newhead,"\n";

foreach my $chr(sort keys %result){
    foreach my $window(sort {$a<=>$b} keys %{$result{$chr}}){
        my @line=($chr,$window,$info{$chr}{$window});
        for(my $i=0;$i<@ind;$i++){
            for(my $j=$i+1;$j<@ind;$j++){
	my $type=$ind[$i]."_".$ind[$j];
	my $dis=$result{$chr}{$window}{$type};
	push @line,$dis;
            }
        }
        print join "\t",@line,"\n";
    }
}

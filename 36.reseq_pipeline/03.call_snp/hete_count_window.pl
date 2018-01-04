#! /usr/bin/env perl
use strict;
use warnings;

# zcat xx.vcf.gz | perl hete_count_window.pl > hete_count_window.pl.out

my $min_dp=2;
my $max_dp=100;
my $min_qual=30;

my %hash;
my @head;
my $control=0;
my $window_size=500000;
while(<>){
    chomp;
    next if(/^##/);
    my @a=split(/\s+/);
    if(/^#/){
        @head=@a;
        next;
    }
    next if(/INDEL/);
    next if($a[5]<$min_qual);
    # last if($a[1]>10000000);
    my $window=int($a[1]/$window_size)*$window_size;
    for(my $i=9;$i<@a;$i++){
        my $id=$head[$i];
        next unless($a[$i]=~/(\d+)$/);
        my $dp=$1;
        next if($dp > $max_dp || $dp < $min_dp);
        if($a[$i]=~/1\/1/){
            $hash{$a[0]}{$window}{$id}{homo}++;
        }
        elsif($a[$i]=~/0\/1/){
            $hash{$a[0]}{$window}{$id}{hete}++;
        }
        elsif($a[$i]=~/0\/0/){
            $hash{$a[0]}{$window}{$id}{anc}++;
        }
    }
    # last if($control++>100000);
}

foreach my $chr(sort keys %hash){
    foreach my $window(sort {$a<=>$b} keys %{$hash{$chr}}){
        foreach my $id(sort keys %{$hash{$chr}{$window}}){
            my $hete=$hash{$chr}{$window}{$id}{hete};
            my $homo=$hash{$chr}{$window}{$id}{homo};
            my $anc=$hash{$chr}{$window}{$id}{anc};
            my $total=$hete+$homo+$anc;
            my $hete_ratio=$hete/$total;
            print "$chr\t$window\t$id\t$hete\t$homo\t$anc\t$hete_ratio\n";
        }
    }
}

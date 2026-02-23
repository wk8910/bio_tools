#! /usr/bin/env perl
use strict;
use warnings;

# zcat xx.vcf.gz | perl hete_count.pl > hete_count.pl.out

my $min_dp=2;
my $max_dp=100;
my $min_qual=30;

my %hash;
my @head;
my $control=0;
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
    for(my $i=9;$i<@a;$i++){
        my $id=$head[$i];
        next unless($a[$i]=~/(\d+)$/);
        my $dp=$1;

        next if($dp > $max_dp || $dp < $min_dp);
        if($a[$i]=~/1\/1/){
            $hash{$id}{homo}++;
        }
        elsif($a[$i]=~/0\/1/){
            $hash{$id}{hete}++;
        }
        elsif($a[$i]=~/0\/0/){
            $hash{$id}{anc}++;
        }
    }
}

foreach my $id(sort keys %hash){
    my $hete=$hash{$id}{hete};
    my $homo=$hash{$id}{homo};
    my $anc=$hash{$id}{anc};
    my $total=$hete+$homo+$anc;
    my $hete_ratio=$hete/$total;
    print "$id\t$hete\t$homo\t$anc\t$hete_ratio\n";
}

#! /usr/bin/env perl
use strict;
use warnings;

open I,"< clean.gff";
my @gene_len;
my @exon_len;
my %cds_len;
my %cds;
my $x=0;
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    if($a[2] eq "gene"){
        my $len=$a[4]-$a[3]+1;
        push @gene_len,$len;
    }
    elsif ($a[2] eq "CDS") {
        my $len=$a[4]-$a[3]+1;
        push @exon_len,$len;
        $a[8]=~/Parent=(.*)/;
        my $id=$1;
        $x++;
        $cds_len{$id}+=$len;
        $cds{$id}{$x}{start}=$a[3];
        $cds{$id}{$x}{end}=$a[4];
    }
}
close I;

my $gene_num=keys %cds;

my @cds_len;
foreach my $id(sort keys %cds_len){
    push @cds_len,$cds_len{$id};
}

my @exon_num;
my @intron_len;
foreach my $id(keys %cds){
    my $num=keys %{$cds{$id}};
    push @exon_num,$num;
    next if($num==1);
    my $pre="NA";
    foreach my $x(sort {$cds{$id}{$a}{start}<=>$cds{$id}{$b}{start}} keys %{$cds{$id}}){
        my $start=$cds{$id}{$x}{start};
        my $end=$cds{$id}{$x}{start};
        if($pre eq "NA"){
            $pre=$end;
            next;
        }
        else {
            my $intron=($start-1)-($pre+1)+1;
            push @intron_len,$intron;
            $pre=$end;
        }
    }
}

my $gene_len=&mean(@gene_len);
my $cds_len=&mean(@cds_len);
my $exon_num=&mean(@exon_num);
my $exon_len=&mean(@exon_len);
my $intron_len=&mean(@intron_len);
print "total_number\taverage_gene_len\taverage_cds_len\taverage_exon_num\taverage_exon_len\taverage_intron_len\n";
print "$gene_num\t$gene_len\t$cds_len\t$exon_num\t$exon_len\t$intron_len\n";

sub mean{
    my @a=@_;
    return "noValue" if(@a==0);
    my $sum=0;
    my $num=0;
    foreach my $a(@a){
        $num++;
        $sum+=$a;
    }
    my $mean=$sum/$num;
    return($mean);
}

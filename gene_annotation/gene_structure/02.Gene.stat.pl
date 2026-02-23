#!/usr/bin/perl -w
use strict;

my %mRNA;
my %cds;
my %select;

my %list=&read_list("00.gff.trans2gene.list");

my @trans2gene=sort keys %{$list{trans}};
for my $trans2gene (@trans2gene){
    $trans2gene=~/(\w+)\.trans2gene.len.txt$/;
    my $id=$1;
    my %flt;
    open (F,"$trans2gene");
    while (<F>) {
        chomp;
        my @a=split(/\s+/,$_);
        $flt{$a[0]}{$a[2]}=$a[1];
    }
    close F;
    for my $k (sort keys %flt){
        my @k2=sort{$b<=>$a} keys %{$flt{$k}};
        my $t=$flt{$k}{$k2[0]};
        $select{$id}{$t}++;
    }
}

my $pacid;
my @gff=sort keys %{$list{gff}};
for my $in (@gff){
    my $type=$list{gff}{$in};
    open (F,"$in")||die"$!";
    $in=~/(\w+)\.gff$/ or die "$in\n";
    my $id=$1;
    while (<F>) {
        chomp;
        next if /^#/;
        next if /^$/;
        my @a=split(/\t/,$_);
        if($a[2] eq 'mRNA'){
            if ($type eq 'NCBI'){
	$a[8]=/ID=([^\;]+)/ or die "41:\t$_\n";
	next if ! exists $select{$id}{$1};
	$mRNA{$id}{$1}=abs($a[4]-$a[3])+1;
            }elsif ($type eq 'Ensembl') {
	$a[8]=/ID=transcript\:(\w+)/ or die "45:\t$_\n";
	next if ! exists $select{$id}{$1};
	$mRNA{$id}{$1}=abs($a[4]-$a[3])+1;
            }else{
	die "wrong type: $type\n";
            }
        }
        if($a[2] eq 'CDS'){
            if ($type eq 'NCBI'){
	$a[8]=~/Parent=([^\;]+)/ or die "51:\t$_\n";
	next if ! exists $select{$id}{$1};
	$cds{$id}{$1}{$a[3]}=$a[4];
            }elsif($type eq 'Ensembl'){
	$a[8]=~/Parent=transcript\:([^;]+)/ or die "56:\t$_\n";
	next if ! exists $select{$id}{$1};
	$cds{$id}{$1}{$a[3]}=$a[4];
            }else{
	die "wrong type: $type\n";
            }
        }
    }
    close F;
}

open (O,">$0.mRNA.len.txt");
for my $k1 (sort keys %mRNA){
    for my $k2 (sort keys %{$mRNA{$k1}}){
        print O "$k1\t$k2\t$mRNA{$k1}{$k2}\n";
    }
}
open (O1,">$0.Exon.len.txt");
open (O2,">$0.Exon.num.txt");
open (O3,">$0.Intron.len.txt");
open (O4,">$0.CDS.len.txt");
for my $k1 (sort keys %cds){
    for my $k2 (sort keys %{$cds{$k1}}){
        my @k3=sort{$a<=>$b} keys %{$cds{$k1}{$k2}};
        my $num=scalar(@k3);
        print O2 "$k1\t$k2\t$num\n";
        my $cdslen=0;
        for my $k3 (@k3){
            my $len=abs($cds{$k1}{$k2}{$k3} - $k3)+1;
            $cdslen += $len;
            print O1 "$k1\t$k2\t$len\n";
        }
        print O4 "$k1\t$k2\t$cdslen\n";
        if ($num>1){
            for (my $i=1;$i<@k3;$i++){
	my @site=sort{$a<=>$b} ($k3[$i-1],$k3[$i],$cds{$k1}{$k2}{$k3[$i-1]},$cds{$k1}{$k2}{$k3[$i]});
	my $len=$site[2]-$site[1]-1;
	print O3 "$k1\t$k2\t$len\n";
            }
        }
    }
}
close O1;
close O2;
close O3;
close O4;

sub read_list{
    my ($in)=@_;
    my %r;
    open (F,"$in")||die"$in\n";
    while (<F>) {
        chomp;
        my @a=split(/\s+/,$_);
        $r{trans}{$a[1]}=$a[2];
        $r{gff}{$a[0]}=$a[2];
    }
    close F;
    return %r;
}

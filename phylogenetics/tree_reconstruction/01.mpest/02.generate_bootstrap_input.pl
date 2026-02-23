#! /usr/bin/env perl
use strict;
use warnings;

my $dir="genes";
my $outdir="bootstrap";
`mkdir $outdir` if(!-e $outdir);

my @genes=<$dir/RAxML_bootstrap.*.phb>;

my $bootstrap_number=100;

my %genes;
my $sn=0;
foreach my $genes(@genes){
    open I,"< $genes";
    my $tmp=0;
    while(<I>){
        chomp;
        $genes{$sn}{$tmp}=$_;
        $tmp++;
    }
    close I;
    $sn++;
}

for(my $i=0;$i<$bootstrap_number;$i++){
    `mkdir $outdir/$i`;
    open O,"> $outdir/$i/all.tre";
    for(my $i=0;$i<$sn;$i++){
        my $select=int(rand($sn));
        my $tmp_num=keys %{$genes{$select}};
        my $tmp=int(rand($tmp_num));
        # print "$select\t$tmp\n";
        my $tree=$genes{$select}{$tmp};
        print O "$tree\n";
    }
    close O;
}

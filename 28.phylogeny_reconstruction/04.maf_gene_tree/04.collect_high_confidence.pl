#! /usr/bin/env perl
use strict;
use warnings;

my $indir="genes";
my $gff="nc_ref.gff"; # genes in chrY will be removed

my %black_list;
open I,"< nc_ref.gff";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    next unless($a[0] eq "chrY" && $a[2] eq "mRNA");
    $a[8]=~/ID=(\w+)/;
    my $id=$1;
    $black_list{$id}=1;
}

my @tree=<$indir/RAxML_bipartitionsBranchLabels.*.phb>;
open O1,"> $0.all.lst";
open O2,"> $0.lst";
open O3,"> $0.all.tre";
open O4,"> $0.tre";
my $control=0;
foreach my $tree(@tree){
    $tree=~/RAxML_bipartitionsBranchLabels\.([^\.]+)\./;
    my $id=$1;
    next if(exists $black_list{$id});
    open I,"< $tree";
    my $line;
    while(<I>){
        chomp;
        $line.=$_;
    }
    my $light=1;
    while($line=~/\[(\d+)\]/g){
        my $bs=$1;
        $light=0 if($bs<70);
    }
    if($light==1){
        print O2 "$id\t$line\n";
        $line=~s/\[\d+\]//g;
        print O4 "$line\n";
    }
    print O1 "$id\t$line\n";
    $line=~s/\[\d+\]//g;
    print O3 "$line\n";
    close I;
    # last if($control++>10);
}
close O1;
close O2;
close O3;
close O4;

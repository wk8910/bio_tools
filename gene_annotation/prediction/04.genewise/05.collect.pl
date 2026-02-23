#! /usr/bin/env perl
use strict;
use warnings;

my $list="corresponding.list";
my $indir="prediction";
my $outdir="result";
`mkdir $outdir` if(!-e $outdir);

open O1,"> $outdir/gene.gff";
open O2,"> $outdir/pseudogene.gff";
open I,"< $list";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my $id=$a[1];
    if(-e "$indir/$id/${id}_result.pep"){
        open P,"< $indir/$id/${id}_result.pep";
        my $test=<P>;
        chomp $test;
        my $light=1;
        if($test=~/pseudo/){
            $light=0;
        }
        else {
            my $test2;
            while (<P>) {
	chomp;
	$test2.=$_;
            }
            $test2=~s/\*$//;
            if($test2=~/\*/){
	$light=0;
            }
        }
        close P;
        open G,"< $indir/$id/${id}_result.gff";
        while (<G>) {
            chomp;
            my @a=split(/\s+/);
            if($a[0]=~/^(\S+):(\d+)-\d+/){
	$a[0]=$1;
            }
            my $line=join "\t",@a;
            if($light==0){
	print O2 "$line\n";
            }
            else {
	print O1 "$line\n";
            }
        }
        close G;
        close P;
    }
}
close I;
close O1;
close O2;

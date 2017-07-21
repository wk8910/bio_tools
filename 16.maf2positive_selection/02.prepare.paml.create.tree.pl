#!/usr/bin/perl
use strict;
use warnings;

## created by Yongzhi Yang. 2017/3/20 ##

my $tree_file=shift;
my @species=@ARGV;
die "Usage:\nperl $0 tree species1 species2 ...
tree file: contains a tree that like ((Ore,Omu),Jre,(Ppe,Fve));
species: the branch you want to mark\n" if scalar(@species) == 0;

my $tree;
open (F,"$tree_file")||die"$!";
while (<F>) {
    chomp;
    $tree=$_;
}
close F;

my $outdir="tree";
`mkdir $outdir` if (! -e "$outdir");
for (my $i=0;$i<=@species;$i++){
    my $j=$i-1;
    if ($i==0){
        open (O,">$outdir/tree.raw");
        print O "$tree\n";
        close O;
    }else{
        my $treenew=$tree;
        while ($treenew=~/([^\(\)\,\;]+)/g) {
            my $k=$1;
            if ($k eq $species[$j]){
	$treenew=~s/$k/$k #1/;
	open (O,">$outdir/tree.$k");
	print O "$treenew\n";
	close O;
            }
        }
    }
}

#! /usr/bin/env perl
use strict;
use warnings;
use List::Util;

my $plink_prefix="plink";
my $pop_list="keep.txt";

my $fam=$plink_prefix.".fam";

my %content;
open I,"< $fam";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my $id=$a[0];
    $content{$id}=$_;
}
close I;

my %pop;
my %select;
open I,"< keep.txt";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($id,$pop)=@a;
    $pop{$pop}{$id}=1;
}
close I;

my $min=-1;
foreach my $pop(sort keys %pop){
    my $num = keys %{$pop{$pop}};
    if($min==-1){
	$min= $num;
    }
    if($min>$min){
	$min=$num;
    }
}

open R,"> $0.sh";
foreach my $pop(sort keys %pop){
    open O,"> $pop.list";
    my @ind=keys %{$pop{$pop}};
    @ind=List::Util::shuffle @ind;
    for(my $i=0;$i<$min;$i++){
	my $id=$ind[$i];
	print O "$content{$id}\n";
    }
    close O;
    print R "plink --bfile plink --r2 gz --ld-window-kb 501 --ld-window 99999 --out $pop --allow-extra-chr --ld-window-r2 0 --keep $pop.list\n";
}
close R;

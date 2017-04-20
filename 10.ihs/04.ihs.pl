#! /usr/bin/env perl
use strict;
use warnings;

my $out="$0.txt";
my $dir="ihs";

my @ihs=<$dir/*.windows>;
open O,"> $out";
print O "chr\tpos\tihs\n";
foreach my $ihs(@ihs){
    $ihs=~/$dir\/(\w+)/;
    my $chr=$1;
    open I,"< $ihs";
    while(<I>){
	chomp;
	my ($start,$end,$n_snp,$ihs,$percent)=split(/\s+/);
	my $pos=int(($start+$end)/200)*100;
	print O "$chr\t$pos\t$percent\n";
    }
    close I;
}
close O;

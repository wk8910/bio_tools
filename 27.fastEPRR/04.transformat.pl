#! /usr/bin/env perl
use strict;
use warnings;

my @recombination=<step3/*>;

open O,"> $0.txt";
print O "chr\tstart\tend\tmid\tRho\tCIL\tCIR\n";
foreach my $file(@recombination){
    open I,"< $file";
    $file=~/chr_([^\/]+)$/;
    my $chr=$1;
    while(<I>){
        chomp;
        /Position\(kb\) ([\d\.]+)-([\d\.]+):/;
        my ($start,$end)=($1,$2);
        $start=int(($start+5)/10)*10;
        $end  =int(($end+5)/10)*10;
        my $mid=($start+$end)/2;
        $start = $start*1000+1;
        $end   = $end*1000+1;
        $mid   = $mid*1000;

        my $value=<I>;
        chomp $value;
        my ($rho,$cil,$cir)=("NA","NA","NA");
        if($value=~/Rho:([\d\.]+) CIL:([\d\.]+) CIR:([\d\.]+)/){
            ($rho,$cil,$cir)=($1,$2,$3);
        }
        elsif($value=~/Rho:([\d\.]+)/){
            $rho=$1;
        }
        print O "$chr\t$start\t$end\t$mid\t$rho\t$cil\t$cir\n";
    }
    close I;
    # last;
}
close O;

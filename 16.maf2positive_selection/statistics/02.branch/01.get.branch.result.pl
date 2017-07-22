#!/usr/bin/perl
use strict;
use warnings;

open (O,">All.branch.out");
#print W N S dN dS
print O "cluster\ttype\tnp\tlnl\tw1\tw2\n";

my $indir="../../genes";
my @mlc=<$indir/*/branch.*.mlc>;
for my $mlc (@mlc){
    next if $mlc=~/freeratio/;
    # print "$mlc\n";
    my $cluster;
    my $type;
    $mlc=~/\S+\/([^\/]+)\/branch.([^\/]+)\.mlc$/ or die"$mlc\n";
    $cluster=$1;
    $type=$2;
    $type=~s/tworatio\.//;
    $type="All" if $type eq "oneratio";
    my ($np,$lnl,$N,$S,$oneratiow);
    my %flt;
    open (F,"$mlc")||die"$!";
    my ($w1,$w2);
    while (<F>) {
        chomp;
        s/^\s+//;
        if (/^lnL\(ntime:\s+\S+\s+np\:\s*(\d+)\)\:\s*(\S+)/){
            $np=$1;
            $lnl=$2;
        }
        if (/^omega\s+\(dN\/dS\)\s+=\s+(\S+)$/){
            ($w1,$w2)=($1,$1);
        }
        if (/^w\s+\(dN\/dS\)\s+for\s+branches:\s+(\S+)\s+(\S+)$/){
            ($w1,$w2)=($1,$2);
        }
    }
    close F;
    print O "$cluster\t$type\t$np\t$lnl\t$w1\t$w2\n";
}
close O;

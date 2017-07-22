#! /usr/bin/env perl
use strict;
use warnings;

my $branch_result="All.branch.out";
my $freeratio_result="../01.freeratio/All.freeratio.result.out";
my $out="All.branch.chi2.out";
my $chi2="/home/share/users/wangkun2010/software/paml/paml4.9e/src/chi2";

my %h;
open (F,"$branch_result")||die"$!";
while (<F>) {
    chomp;
    my @a=split(/\s+/,$_);
    next if /^cluster\s+/;
    next if ! $a[2];
    $h{$a[0]}{$a[1]}{np}=$a[2];
    $h{$a[0]}{$a[1]}{lnl}=$a[3];
    $h{$a[0]}{$a[1]}{line}=$_;
}
close F;
my %pass;
open (F,"$freeratio_result")||die"$!";
<F>;
while (<F>) {
    chomp;
    my @a=split(/\s+/,$_);
    $pass{$a[0]}++ if (($a[1]<150) || ($a[6]>2));
}
close F;

open (O,">$out");
print O "cluster\ttype\tA_w\tB_w\tS_w\tA_np\tA_lnl\tS_np\tS_lnl\t\tdelta_np\tdelta_lnl\tP\n";
for my $k1 (sort keys %h){
    next if exists $pass{$k1};
    my @k2=sort keys %{$h{$k1}};
    for my $k2 (@k2){
        next if $k2 eq 'All';
        my $cluster=$k1;
        my $k3="All";
        my $type="$k2-VS-$k3";
        my $bnp=$h{$k1}{$k3}{np};
        my $blnl=$h{$k1}{$k3}{lnl};
        my $snp=$h{$k1}{$k2}{np};
        my $slnl=$h{$k1}{$k2}{lnl};
        my $deltalnl=2 * abs($slnl-$blnl);
        my $deltanp=$snp-$bnp;

        my $p=`$chi2 $deltanp $deltalnl`;
        chomp $p;
        $p=~/prob\s*=\s*(\S+)/ or die "$p\n";
        $p=$1;
        my $line1=$h{$k1}{$k2}{line};
        my $line2=$h{$k1}{$k3}{line};
        #my $j=($i*3) + 5;
        my @line1=split(/\s+|\:/,$line1);
        my @line2=split(/\s+|\:/,$line2);
        my $aw=$line2[4];
        my $bw=$line1[4];
	my $sw=$line1[5];
        print O "$cluster\t$type\t$aw\t$bw\t$sw\t$bnp\t$blnl\t$snp\t$slnl\t$deltanp\t$deltalnl\t$p\n";
    }
}
close O;

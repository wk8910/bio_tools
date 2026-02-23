#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my @bam=<bam/*>;
my $outdir="01.bamBySample";
`mkdir $outdir` if(!-e $outdir);

my %hash;
foreach my $bam(@bam){
    # print "$bam\n";
    $bam=~/([^\/]+)\.(\d+)\.bam$/;
    my ($ind,$soldier)=($1,$2);
    # print "$ind\t$soldier\n";
    $hash{$ind}{$bam}=1;
}

open(O,"> $0.sh");
foreach my $ind(sort keys %hash){
    my @bam=sort keys %{$hash{$ind}};
    next if(-e "$now/$outdir/$ind.bam");
    if(@bam==1){
	print O "ln -s $now/$bam[0] $now/$outdir/$ind.bam\n";
    }
    elsif(@bam>1){
	my @in;
	foreach my $bam(@bam){
	    push @in,"$now/$bam";
	}
	print O "/home/share/user/user101/bin/samtools merge -l 3 --threads 3 $now/$outdir/$ind.bam ",join " ",@in,"\n";;
    }
}
close O;

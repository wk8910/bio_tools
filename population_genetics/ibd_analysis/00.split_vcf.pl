#! /usr/bin/env perl
use strict;
use warnings;

my $vcf="plink.vcf";
my $outdir="vcf";
`mkdir $outdir` if(!-e $outdir);

my %fh;
open I,"< $vcf";
my $head;
while(<I>){
    if(/^#/){
	$head.=$_;
    }
    else{
	my @a=split(/\s+/);
	my $chr=$a[0];
	if(!exists $fh{$chr}){
	    open $fh{$chr},"> $outdir/$chr.vcf";
	    $fh{$chr}->print("$head");
	}
	$fh{$chr}->print("$_");
    }
}
close I;

foreach my $chr(keys %fh){
    close $fh{$chr};
}

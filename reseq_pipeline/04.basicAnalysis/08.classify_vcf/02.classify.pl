#! /usr/bine/env perl
use strict;
use warnings;

my $vcf="all_keep.vcf.gz";
my $out_snp="snp.vcf.gz";
my $out_indel="indel.vcf.gz";
my $out_all="snpAndNonSnp.vcf.gz";

open I,"zcat $vcf |";
open O1,"| bgzip -c > $out_snp";
open O2,"| bgzip -c > $out_indel";
open O3,"| bgzip -c > $out_all";
while(<I>){
    chomp;
    if(/^#/){
	print O1 "$_\n";
	print O2 "$_\n";
	print O3 "$_\n";
	next;
    }
    else{
	my @a=split(/\s+/);
	if($a[4] eq "<NON_REF>" || $a[4] eq "*" || $a[4] eq "."){
	    if(/0\/1/ or /1\/1/){
		# print "$_\n";
		next;
	    }
	    else{
		$a[4]=$a[3];
	    }
	}
	next if($a[4]=~/\,/);

	if( length($a[3])>1 or length($a[4])>1){
	    next if($a[3] eq $a[4]);
	    print O2 join "\t",@a,"\n";
	}
	elsif($a[3] ne $a[4]){
	    print O1 join "\t",@a,"\n";
	    print O3 join "\t",@a,"\n";
	}
	else{
	    print O3 join "\t",@a,"\n";
	}
    }
}
close O1;
close O2;
close O3;
close I;

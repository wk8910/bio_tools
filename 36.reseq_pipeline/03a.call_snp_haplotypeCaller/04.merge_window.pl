#! /usr/bin/env perl
use strict;
use warnings;

my @vcf=<03.step3_hardfilter/*.filter_snp.vcf.gz>;
my $out="$0.vcf.gz";

my %hash;
foreach my $vcf(@vcf){
    $vcf=~/(\d+)\.filter_snp\.vcf\.gz/;
    my $order=$1;
    $hash{$order}=$vcf;
}

@vcf=();
foreach my $order(sort {$a<=>$b} keys %hash){
    push @vcf,$hash{$order};
    # print "$order\t$hash{$order}\n";
}

print STDERR "Reading vcf now!\n";

my $control=0;
open(O,"| gzip - >  $out");
foreach my $vcf(@vcf){
    print STDERR "Reading $vcf\n";
    open(I,"zcat $vcf |");
    while(<I>){
	chomp;
	if(/^#/){
	    next unless($control==0);
	    print O "$_\n";
	}
	else{
	    my @a=split(/\s+/);
	    next unless(length($a[3])== 1 && length($a[4]) == 1);
            next unless($a[4]=~/^[ATCG]+$/);
	    next unless($a[6]=~/^PASS/);
	    print O "$_\n";
        }
    } 
    close I;
    $control++;
}
close O;

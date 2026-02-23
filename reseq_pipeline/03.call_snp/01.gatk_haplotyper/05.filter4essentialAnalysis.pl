#! /usr/bin/env perl
use strict;
use warnings;

my $vcf="04.extractBiAllelicVar.pl.vcf.gz";
open(I,"zcat $vcf |");
my %indel;
my $control=0;
while(<I>){
    chomp;
    next if(/^#/);
    my @a=split(/\s+/);
    my ($chr,$pos,$ref,$alt)=($a[0],$a[1],$a[3],$a[4]);
    my $len_ref=length($ref);
    my $len_alt=length($alt);
    next unless($len_ref ne $len_alt);
    # print "$chr\t$pos\t$ref\t$alt\n";
    for(my $i=-5;$i<$len_ref+5;$i++){
	my $del_pos=$pos+$i;
	my $bar_code=$chr."-".$del_pos;
	$indel{$bar_code}=1;
    }
    if($control++ % 10000 == 0){
	print STDERR "$chr\t$pos\n";
    }
    # last if($control++>100);
    # exit();
}
close I;
print STDERR "Indels loaded!\n";

open(I,"zcat $vcf |");
open(O,"| gzip - > $0.vcf.gz");
while(<I>){
    chomp;
    if(/^#/){
	print O "$_\n";
	next;
    }
    my @a=split(/\s+/);
    my ($chr,$pos,$ref,$alt)=($a[0],$a[1],$a[3],$a[4]);
    my $bar_code=$chr."-".$pos;
    next if(exists $indel{$bar_code});
    my $missing_num=0;
    my $total_num=0;
    for(my $i=9;$i<@a;$i++){
	$total_num++;
	my @b=split(":",$a[$i]);
	if($b[0]=~/\.\/\./){
	    $missing_num++;
	}
    }
    # print "$missing_num\t$total_num\n";
    next if($missing_num/$total_num >= 0.1);
    print O "$_\n";
}
close O;
close I;


#! /usr/bin/env perl
use strict;
use warnings;

my ($vcf,$outdir)=@ARGV;
die "Usage: $0 <vcf file> <outdir>\n" if(!-e $vcf || ! $outdir);
my $wind_size=100000;

`mkdir $outdir` if(!-e $outdir);

if($vcf=~/.gz$/){
    open I,"zcat $vcf |" or die "Cannot open $vcf!\n";
}
else{
    open I,"< $vcf" or die "Cannot open $vcf!\n";
}

my $code="NA";
my $control=0;
my $head;
while(<I>){
    if(/^#/){
	$head.=$_;
	next;
    }
    my @a=split(/\s+/);
    my ($chr,$pos)=($a[0],$a[1]);
    my $index=int($pos/$wind_size)*$wind_size;
    $index = $chr.".".$index;
    # print STDERR "$index\n";
    if($index ne $code){
	print STDERR "$index\n";
	close O;
	open O,"| gzip - > $outdir/$index.vcf.gz ";
	print O "$head";
	# last if($control++>100);
    }
    $code=$index;
    print O "$_";
}
close O;
close I;

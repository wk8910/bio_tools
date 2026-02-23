#! /usr/bin/env perl
use strict;
use warnings;

my $keep="Y1.lst";
my $vcf="all79.vcf.gz";
my $out="Y1.vcf.gz";

my %keep;
open I,"< $keep";
while(<I>){
    chomp;
    /^(\S+)/;
    my $ind=$1;
    $keep{$ind}=1;
}
close I;

open O,"| gzip - > $out";
open I,"zcat $vcf |";
my @head;
my @keep;
while(<I>){
    chomp;
    if(/^##/){
	print O "$_\n";
    }
    elsif(/^#/){
	@head=split(/\s+/);
	for(my $i=9;$i<@head;$i++){
	    my $ind=$head[$i];
	    if(exists $keep{$ind}){
		push @keep,$i;
	    }
	}
	my @line;
	for(my $i=0;$i<9;$i++){
	    push @line,$head[$i];
	}
	foreach my $i(@keep){
	    push @line,$head[$i];
	}
	print O join "\t",@line,"\n";
    }
    else{
	my @a=split(/\s+/);
	my @line;
	for(my $i=0;$i<9;$i++){
	    push @line,$a[$i];
	}
	foreach my $i(@keep){
	    push @line,$a[$i];
	}
	print O join "\t",@line,"\n";
    }
}
close I;
close O;

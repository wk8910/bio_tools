#! /usr/bin/env perl
use strict;
use warnings;

my $keep=shift;
my $vcf="all.vcf.gz";

if(!-e "$keep"){
    die "Usage: $0 <keep ind list>\n";
}

my %keep;
open I,"< $keep";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    $keep{$a[0]}=1;
}
close I;

my @head;
open I,"zcat $vcf |";
open O,"| gzip - > $keep.vcf.gz";
while(<I>){
    chomp;
    if(/^##/){
	print O "$_\n";
	next;
    }
    if(/^#/){
	@head=split(/\s+/);
	my @new_head;
	for(my $i=0;$i<9;$i++){
	    $new_head[$i]=$head[$i];
	}
	for(my $i=9;$i<@head;$i++){
	    my $id=$head[$i];
	    if(exists $keep{$id}){
		push @new_head,$id;
	    }
	}
	print O join "\t",@new_head,"\n";
	next;
    }
    my @a=split(/\s+/);
    $a[4]=($a[4] eq ".")? $a[3]:$a[4];
    next unless($a[3] ne $a[4]);
    my @new_line;
    for(my $i=0;$i<9;$i++){
	$new_line[$i]=$a[$i];
    }
    for(my $i=9;$i<@a;$i++){
	my $id=$head[$i];
	if(exists $keep{$id}){
	    push @new_line,$a[$i];
	}
    }
    print O join "\t",@new_line,"\n";
}
close I;
close O;

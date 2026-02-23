#! /usr/bin/env perl
use strict;
use warnings;

my $csv="mito.csv"; # mega ancestral output ML method : export most probable sequences
my $comb="comb.txt"; # the id in mito.csv, example: 1 10\n2 10\n

open I,"< $csv";
my @result;
my %result;
while(<I>){
    chomp;
    s/\s//g;
    if(/^,$/){
	&analysis(@result);
	@result=();
	# last;
    }
    else{
	push @result,$_;
    }
}
close I;

my %seq;
foreach my $id(sort keys %result){
    my @base;
    foreach my $base_id(sort {$a<=>$b} keys %{$result{$id}}){
	push @base,$result{$id}{$base_id};
    }
    my $seq=join "",@base;
    $seq{$id}=$seq;
    # print ">$id\n$seq\n";
}

open I,"< $comb";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my $seq1=$seq{$a[0]};
    my $seq2=$seq{$a[1]};
    my ($all,$diff)=&count($seq1,$seq2);
    push @a,($all,$diff);
    print join "\t",@a,"\n";
    
}
close I;

sub count{
    my ($seq1,$seq2)=@_;
    my @seq1=split(//,$seq1);
    my @seq2=split(//,$seq2);
    my ($all,$diff)=(0,0);
    for(my $i=0;$i<@seq1;$i++){
	$all++;
	if($seq1[$i] ne $seq2[$i]){
	    $diff++;
	}
    }
    return($all,$diff);
}

sub analysis{
    my @result=@_;
    my $head=shift @result;
    my @head=split(/,/,$head);
    foreach my $line(@result){
	my @base=split(/,/,$line);
	my $id=shift @base;
	$id=~/^(\d+)\./;
	$id=$1;
	# print "$id\n";
	for(my $i=0;$i<@base;$i++){
	    my $base_id=$head[$i];
	    $result{$id}{$base_id}=$base[$i];
	}
    }
}

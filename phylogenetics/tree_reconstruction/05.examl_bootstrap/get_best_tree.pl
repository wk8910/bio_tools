#! /usr/bin/env perl
use strict;
use warnings;

my $char=shift;

my @log=<ExaML_log.$char.*>;

my %hash;
foreach my $log(@log){
    $log=~/(\d+)$/;
    my $id=$1;
    open I,"< $log";
    my $likelihood;
    while(<I>){
	chomp;
	my @a=split(/\s+/);
	$likelihood=$a[1];
    }
    close I;
    $hash{$id}=$likelihood;
}

foreach my $id(sort {$hash{$b} <=> $hash{$a}} keys %hash){
    # print "$id\n";
    `cp ExaML_result.main.tre.$id ExaML_result.main.tre`;
    last;
}

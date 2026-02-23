#! /usr/bin/perl
use strict;
use warnings;

my @line=`wc -l step1/*`;

`mkdir step1.discard` if(!-e "step1.discard");

foreach my $line(@line){
    chomp $line;
    next if($line!~/step/);
    $line=~s/^\s*//;
    $line=~/^(\d+)\s+(\S+)/;
    my $num=$1;
    my $file=$2;
    if($num==1){
	print "$line\n";
	`mv $file step1.discard`;
    }
    # last;
}

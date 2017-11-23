#! /usr/bin/env perl
use strict;
use warnings;

my @sh=<*.blueprint.sh>;

if(@sh > 1){
    print "only one blueprint.sh file should be existed\n";
    exit();
}

my $sh_file=$sh[0];

open(I,"< $sh_file");
open(O,"> $0.sh");
my $control=0;
while(<I>){
    chomp;
    if(/^# Step 2/){
	$control=1;
    }
    next unless($control==1);
    next if(/^#/);
    if(/^java/){
	s/java/\/home\/share\/software\/java\/jdk1.8.0_05\/bin\/java/;
    }
    print O "$_\n";
}
close I;
close O;


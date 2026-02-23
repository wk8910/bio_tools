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
    if(/^#/){
	$control++;
    }
    if($control==2){
	last;
    }
    next if(/^#/);
    s/^java //;
    print O "/home/share/software/java/jdk1.8.0_05/bin/java $_\n";
}
close I;
close O;

`rm -r qsub; /share/work/software/scripts/buildSGESubmit.pl $0.sh java 1 1 qsub`;

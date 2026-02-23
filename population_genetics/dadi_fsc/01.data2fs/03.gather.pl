#! /usr/bin/env perl
use strict;
use warnings;

my $indir="02.convert_fs";
my $out="$0.fs";

my @fs=<$indir/*.fs>;
open O,"> $out" or die "Cannot create $out\n";
my $control=0;
my $head;
my $tail;
my @content;
foreach my $fs(@fs){
    open I,"< $fs" or die "Cannot read $fs\n";
    $head=<I>;
    chomp $head;

    my $content=<I>;
    chomp $content;
    my @a=split(/\s+/,$content);
    for(my $i=0;$i<@a;$i++){
        $content[$i]+=$a[$i];
    }

    $tail=<I>;
    chomp $tail;
    close I;
    $control++;
}

print O "$head\n";
print O join " ",@content,"\n";
# print O "$tail\n";
close O;

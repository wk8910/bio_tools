#! /usr/bin/env perl
use strict;
use warnings;

my $obs=shift;

die "Usage: $0 <obs file>\n" if(!$obs);

open(I,"< $obs") or die "Cannot open $obs!\n";
my $col_number=0;
my $row_number=0;
<I>;
<I>;
my @data;
while (<I>) {
    my @a=split(/\s+/);
    shift @a;
    @data=(@data,@a);
    $row_number=@a;
    $col_number++;
}
close I;

my $fs="$obs.fs";
open(O,"> $fs") or die "Cannot create $fs\n";
print O "$col_number $row_number\n";
print O join " ",@data,"\n";
close O;

my $effectiveLength="$obs.effectiveLength";
open(O,"> $effectiveLength") or die "Cannot create $effectiveLength\n";
my $sum=sum(@data);
print O "$sum\n";
close O;

sub sum{
    my @array=@_;
    my $sum;
    foreach my $x(@array){
        $sum+=$x;
    }
    return($sum);
}

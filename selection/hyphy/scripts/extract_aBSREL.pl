#! /usr/bin/env perl
use strict;
use warnings;
use JSON;

my $file=shift;
open I,"< $file";
my @lines=<I>;
close $file;

my $line=join "",@lines;

my $result=decode_json($line);

foreach my $species(sort keys %{${$result}{"branch attributes"}{"0"}}){
    my $pvalue=${$result}{"branch attributes"}{"0"}{$species}{"Uncorrected P-value"};
    my $p_corrected=${$result}{"branch attributes"}{"0"}{$species}{"Corrected P-value"};
    my $ratio=${$result}{"branch attributes"}{"0"}{$species}{"Rate Distributions"};
    my @ratio=@$ratio;
    my %ratio;
    $ratio{low}{value}="NA";
    $ratio{low}{percent}="NA";
    $ratio{high}{value}="NA";
    $ratio{high}{percent}="NA";
    foreach my $x(@ratio){
        my @x=@$x;
        if($x[0]<=1){
            $ratio{low}{value}=$x[0];
            $ratio{low}{percent}=$x[1];
        }
        if($x[0]>1){
            $ratio{high}{value}=$x[0];
            $ratio{high}{percent}=$x[1];
        }
    }
    print "$species\t$pvalue\t$p_corrected\t$ratio{low}{value}\t$ratio{low}{percent}\t$ratio{high}{value}\t$ratio{high}{percent}\n";
}

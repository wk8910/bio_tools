#! /usr/bin/env perl
use strict;
use warnings;

my @mem=`ipcs -m`;

foreach my $mem(@mem){
    my @a=split(/\s+/,$mem);
    next unless($a[1]);
    next unless($a[1]=~/^\d+$/);
    print STDERR  "iprcrm -m $a[1]\n";
    `ipcrm -m $a[1]`;
}

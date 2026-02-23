#! /usr/bin/env perl
use strict;
use warnings;

my $dir="bootstrap";

my @bootstrap=<$dir/*>;

open O,"> $0.sh";
foreach my $bootstrap(@bootstrap){
    print O "perl 01.generate_control_file.pl $bootstrap/all.tre > $bootstrap/control_file; ~/software/MP-EST/mpest_1.5/src/mpest $bootstrap/control_file\n";
}
close O;


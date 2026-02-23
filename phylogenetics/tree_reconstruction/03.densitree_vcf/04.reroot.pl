#! /usr/bin/env perl
use strict;
use warnings;

my $dir="output"; # use fasttree output
my $phyutility="/home/share/users/wangkun2010/software/phyutility/phyutility/phyutility.jar";
my $outgroup="bbu01 buffalo001 buffalo002 buffalo003";

open O,"> $0.sh";
print O "cat $dir/*/*.tre > $0.alltre\njava -jar $phyutility -rr -in $0.alltre -out $0.rrtre -names $outgroup\n";
close O;

#! /usr/bin/env perl
use strict;
use warnings;

my $smc="/home/share/user/user101/software/smcpp/smcpp-build/bin/smc++";
my $input_dir="smc_analysis";
my $generation=15;

my @pop=<$input_dir/*>;

my $json="";
open O,"> $0.sh";
foreach my $pop(@pop){
    $pop=~/([^\/]+)$/;
    my $id=$1;
    # print O "$smc plot -g 1 $id.pdf $pop/model.final.json\n";
    $json .= "$pop/model.final.json ";
}

print O "$smc plot -g $generation $0.pdf $json\n";

close O;

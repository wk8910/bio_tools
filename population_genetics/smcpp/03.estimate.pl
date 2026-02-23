#! /usr/bin/env perl
use strict;
use warnings;

my $smc="/home/share/user/user101/software/smcpp/smcpp-build/bin/smc++";
my $miu = 3.75e-8; # per site per generation
my $input_dir="smc_input";
my $out_dir="smc_analysis";
`mkdir $out_dir` if(!-e $out_dir);

my @pop=<$input_dir/*>;

open O,"> $0.sh";
my $theta = $miu * 2 * 1e4; # 1e4 is the default value of --N0
foreach my $pop(@pop){
    $pop=~/([^\/]+)$/;
    my $id=$1;
    # print O "$smc estimate --fold --theta $theta -o $out_dir/$id $pop/*.smc.gz\n";
    print O "$smc estimate --theta $theta -o $out_dir/$id $pop/*.smc.gz\n";
}
close O;

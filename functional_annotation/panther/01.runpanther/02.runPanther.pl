#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my $indir="proteins";
my $tmpdir="tmp";
`mkdir $tmpdir` if(!-e $tmpdir);
my $prefix='export PERL5LIB=$PERL5LIB:/home-gg/users/nsgg121_QQ/software/panther/pantherScore2.1/lib';
my $panther="/home-gg/users/nsgg121_QQ/software/panther/pantherScore2.1/pantherScore2.1.pl";
my $database="/home-gg/users/nsgg121_QQ/software/panther/PANTHER12.0";
my $hmm="/home-gg/users/nsgg121_QQ/software/hmmer/hmmer-3.1b2-linux-intel-x86_64-build/bin";

my @pep=<$indir/*.pep>;

open O,"> $0.sh";
foreach my $pep(@pep){
    $pep=~/([^\/]+)$/;
    my $filename=$1;
    my $tmp="$now/$tmpdir/$filename";
    `mkdir $tmp` if(!-e $tmp);
    print O "$prefix; perl $panther -l $database -D B -V -H $hmm -i $now/$pep -o $now/$pep.out -n -c 5 -T $tmp\n";
}
close O;

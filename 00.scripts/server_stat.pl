#! /usr/bin/env perl
use strict;
use warnings;

my @nodes=(1..7,"f");
my @old=(2..4);
my $cmd="cat /proc/loadavg";

print "node\tload_average\n";
foreach my $i(@nodes){
    my $server="node".$i;
    my $s_cmd="ssh $server '$cmd'";
    #print "$s_cmd\n";
    my $load=`$s_cmd`;
    chomp $load;
    print "node$i:\t$load\n";
}

foreach my $a(@old){
    my $b="old".$a;
    my $c="ssh $b '$cmd'";
    my $d=`$c`;
    chomp $d;
    print "old$a:\t$d\n";	
}

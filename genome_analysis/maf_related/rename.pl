#! /usr/bin/env perl
use strict;
use warnings;

my $name1="pol";
my $name2="gac";

print "##maf version=1 scoring=last\n";
while(my $line=<>){
    if($line=~/^#/){
        next;
    }
    elsif($line=~/^p/){
        next;
    }
    else{
        print "$line";
    }
    if($line=~/^a score/){
        my $first = <>;
        my $second = <>;
        $first=~s/^s\s/s $name1./;
        $second=~s/^s\s/s $name2./;
        print "${first}${second}";
    }
}

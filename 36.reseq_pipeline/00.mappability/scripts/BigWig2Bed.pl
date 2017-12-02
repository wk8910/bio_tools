#!/usr/bin/perl -w
sub usage (){
    die qq(
      #===========================================================================
      #        USAGE:/home/junzli_lab/yulywang/bin/BigWig2Bed.pl  -h
      #        DESCRIPTION: -h : Display this help
      #                          Test with Big2BedGraph Results, 1-based here.
      #        Author: Wang Yu
      #        Mail: yulywang\@umich.edu
      #        Created Time:  Fri 29 Jan 2016 12:12:33 PM EST
      #===========================================================================
    )
}
use strict;
use warnings;
use Getopt::Std;
$ARGV[0] || &usage();
our ($opt_h);
getopts("h");

my $position = 0;
my $chr = "";
my $step = 1;
my $span = 1;
my $map = 0 ;

while(my $line = <>){
    chomp $line;
    if($line =~/variableStep\s+?chrom=([\dXMa-zA-Z]+)\s+?span=(\d+)/){
        $chr = $1;
        $span = $2 -1;
    }
    elsif($line =~/variableStep\s+?chrom=([\dXMa-zA-Z]+)/){
        $chr = $1;
        $span = 0 ; # change every new chr
    }
    else{
        ($step,$map) = split(/\s+/,$line);
        $map = int($map*150+0.5)/150;
        print "$chr\t$step\t",$step+$span,"\t$map\n";
        $step = 0;
        #$span = 0; # span does not change, if they are marked
        $map = 0;
    }
}

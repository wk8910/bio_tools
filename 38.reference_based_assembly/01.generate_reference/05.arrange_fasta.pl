#! /usr/bin/env perl
use strict;
use warnings;

my $in="raw.fa";
my $out="final.fa";
my $dict="cattle.dict";

my %fa;
open I,"perl ~/bio_tools/00.scripts/read_fasta.pl $in |" or die "Could not read $in\n";
while (my $id=<I>) {
    chomp $id;
    my $seq=<I>;
    chomp $seq;
    $fa{$id}=$seq;
}
close I;

print STDERR "$in loaded...\n";

open O,"> $out" or die "Could not create $out\n";
open I,"< $dict" or die "Count not read $dict\n";
while (<I>) {
    chomp;
    next unless(/SN:(\S+)\s+LN:(\d+)/);
    my ($chr,$len)=($1,$2);
    print STDERR "print $chr\n";
    my $seq;
    if(exists $fa{$chr}){
        $seq=$fa{$chr};
    }
    else {
        $seq="N" x $len;
    }
    my $raw_len=length($seq);
    if($raw_len>$len){
        $seq=substr($seq,0,$len);
    }
    elsif($raw_len<$len){
        my $add=($len-$raw_len);
        $add="N" x $add;
        $seq=$seq.$add;
    }
    my @base=split(//,$seq);
    print O ">$chr\n";
    for(my $i=0;$i<@base;$i++){
        if($i%100 == 0){
            print O "\n" if($i>0);
        }
        print O "$base[$i]";
    }
    print O "\n";
}
close I;
close O;

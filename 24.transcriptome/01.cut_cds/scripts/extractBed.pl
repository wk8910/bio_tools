#! /usr/bin/env perl
use strict;
use warnings;

my $info=shift;
my $fa=shift;

my %hash;
open I,"< $info";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($start,$end)=(@a);
    for(my $i=$start;$i<=$end;$i++){
        $hash{$i}=1;
    }
}
close I;

open I,"perl ~/bio_tools/00.scripts/read_fasta.pl $fa |";
while (my $id=<I>) {
    chomp $id;
    my $seq=<I>;
    chomp $seq;
    my @a=split(//,$seq);
    my $real_pos=0;
    my $start_pre="NA";
    my $end_pre="NA";
    for(my $i=0;$i<@a;$i++){
        my $pos=$i+1;
        if($a[$i]!~/-/){
            $real_pos++;
        }
        if(exists $hash{$pos}){
            if($start_pre eq "NA"){
	$start_pre=$real_pos;
	$end_pre=$real_pos;
            }
            elsif ($real_pos-$end_pre==1) {
	$end_pre=$real_pos;
            }
            elsif($real_pos-$end_pre>1){
	print "$id\t$start_pre\t$end_pre\n";
	$start_pre=$real_pos;
	$end_pre=$real_pos;
            }
            else {
	print STDERR "This could not happen!\n";
            }
        }
    }
    if($start_pre ne "NA"){
        print "$id\t$start_pre\t$end_pre\n";
    }
}
close I;


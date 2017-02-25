#! /usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

my $file=shift;

my $fa=Bio::SeqIO->new(-file=>$file,-format=>'fasta');

while(my $seq_obj=$fa->next_seq){
    my $id=$seq_obj->id;
    my $seq=$seq_obj->seq;
    print ">$id\n$seq\n";
}

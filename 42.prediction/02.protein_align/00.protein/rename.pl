#! /usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

my $file=shift;

my $fa=Bio::SeqIO->new(-file=>$file,-format=>'fasta');
$file=~/(\w+)\.pep$/;
my $species=$1;
# print "$species\n";
# =cut
open O,"> $species.pep";
while(my $seq_obj=$fa->next_seq){
    my $id=$seq_obj->id;
    my $seq=$seq_obj->seq;
    if($id!~/\|/){
        print O ">$species|$id\n$seq\n";
    }
    else {
        print O ">$id\n$seq\n";
    }
}
close O;

#! /usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

my $file=shift;

my $fa=Bio::SeqIO->new(-file=>$file,-format=>'fasta');

while(my $seq_obj=$fa->next_seq){
    my $id=$seq_obj->id;
    my $seq=$seq_obj->seq;
    $seq=&translate_nucl($seq);
    print ">$id\n$seq\n";
}

sub translate_nucl{
    my $seq=shift;
    my $seq_obj=Bio::Seq->new(-seq=>$seq,-alphabet=>'dna');
    my $pro=$seq_obj->translate;
    $pro=$pro->seq;
    return($pro);
}

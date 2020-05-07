#! /usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

my $file=shift;
$file=~/(SRR\w+)/;
my $tissue=$1;

my $fa=Bio::SeqIO->new(-file=>$file,-format=>'fasta');

my $num=0;
open O,"> $tissue/coding.cds";
open P,"> $tissue/coding.pep";
while(my $seq_obj=$fa->next_seq){
    $num++;
    my $prefix="0" x (10-length($num));
    my $x=10-length($num);
    $prefix="$tissue|".$prefix.$num;
    my $id=$seq_obj->id;
    my $seq=$seq_obj->seq;
    my $pep=&translate_nucl($seq);
    print O ">$prefix\n$seq\n";
    print P ">$prefix\n$pep\n";
}
close O;
close P;

sub translate_nucl{
    my $seq=shift;
    my $seq_obj=Bio::Seq->new(-seq=>$seq,-alphabet=>'dna');
    my $pro=$seq_obj->translate;
    $pro=$pro->seq;
    return($pro);
}

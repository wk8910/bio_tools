#!/usr/bin/perl
use warnings;
use strict;
use Bio::SeqIO;

my $inputfa=shift or die "perl $0 fa\n";

$inputfa =~ /\/(\w+)\.[^\/]+$/;
my $sp=$1;
my $chr=0;
my $len=0;
my $fa;
if ($inputfa=~/(gz|gzip)/){
    open my $zcat,"zcat $inputfa|" or die "$!";
    $fa=Bio::SeqIO->new(-fh=> $zcat ,-format=>"fasta");
}else{
    $fa=Bio::SeqIO->new(-file=>$inputfa,-format=>'fasta');
}
while(my $seq=$fa->next_seq){
    my $id=$seq->id;
    my $seq=$seq->seq;
    $chr++;
    $seq=~s/n//ig;
    $len += length($seq);
}
print "$sp\t$chr\t$len\n";

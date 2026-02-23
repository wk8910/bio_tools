#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

my ($in,$out)=@ARGV;
die"Usage:\nperl $0 GblocksOutput PamlOutput\n" if (! $out);

my %seq;
my $len;
my $fa=Bio::SeqIO->new(-file=>"$in",-format=>"fasta");
while (my $seq=$fa->next_seq) {
    my $id=$seq->id;
    my $seq=$seq->seq;
    $seq=~s/\s+//g;
    $seq{$id}=$seq;
    $len=length($seq);
}
open (O,">$out");
print O "\t",scalar(keys %seq),"\t$len\n";
for my $k (sort keys %seq){
    print O "$k\n";
    my @seq=split(//,$seq{$k});
    my $end=@seq;
    for (my $i=0;$i<$end;$i++){
        print O "$seq[$i]";
        if (($i+1) % 60 ==0){
            print O "\n";
        }
    }

    if ($len % 60 != 0){
        print O "\n";
    }
}
close O;

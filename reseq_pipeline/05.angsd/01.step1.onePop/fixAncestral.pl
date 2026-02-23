use strict;
use warnings;
use Bio::SeqIO;

my %h;
open (F,"/home/pool_3/users/wangkun2010/deepsea_pacbio/01.genome/ds.dict");
while (<F>) {
    chomp;
    if (/^\@SQ\s+SN:(\w+)\s+LN:(\d+)/){
        $h{$1}=$2;
    }
}
close F;

my %out;
my $fa=Bio::SeqIO->new(-file=>"ancestral",-format=>"fasta");
while (my $seq=$fa->next_seq) {
    my $id=$seq->id;
    my $seq=$seq->seq;
    my $len=$h{$id};
    $out{$id}++;
    my $num=$len - length($seq);
    if ($num>0){
        my $n='N' x $num;
        $seq=$seq.$n;
    }
    print ">$id\n$seq\n";
}

for my $k (sort keys %h){
    my $len=$h{$k};
    next if exists $out{$k};
    my $n='N' x $len;
    print ">$k\n$n\n";
}

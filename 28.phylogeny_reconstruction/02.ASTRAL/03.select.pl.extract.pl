use strict;
use warnings;
use Bio::SeqIO;

my $geneid=shift or die "perl $0 geneid\n";
my $indir="CDS_consensus_fa/$geneid";
my $outdir="Merge_CDS_for_Tree/$geneid";

my %seq;

my @in=<$indir/*.ind.fa>;
for my $in (@in){
    my $fa=Bio::SeqIO->new(-format=>"fasta",-file=>"$in");
    while (my $seq=$fa->next_seq) {
        my $id=$seq->id;
        my $seq=uc($seq->seq);
        my $nonseq=$seq;
        my $length0=length($seq);
        $nonseq=~s/[nN-]//gi;
        my $per=length($nonseq)/length($seq);
        next if $per<0.5;
        $seq{$id}=$seq;
    }
}

`mkdir -p $outdir` if (! -e "$outdir");

open (O,">$outdir/cds.fas");
for my $k (sort keys %seq){
    my $outseq=$seq{$k};
    $outseq=~s/N/-/g;
    print O ">$k\n$outseq\n";
}
close O;

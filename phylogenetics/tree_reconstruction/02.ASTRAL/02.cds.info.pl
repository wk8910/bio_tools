use strict;
use warnings;
use Bio::SeqIO;

my $indir=shift or die "perl $0 inputdir\n";
$indir=~/\/(OreG\d+)/ or die "$indir\n";
my $geneid=$1;
my %seq;
my %count;
my %len;

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
        $len{$length0}++;
    }
}

exit if scalar(keys %seq) == 0;
my @len=sort keys %len;
die "wrong length $indir\n" if scalar(@len)>1;
my @k1=sort keys %seq;

for my $k (sort keys %seq){
    my @seq=split(//,$seq{$k});
    for (my $i=0;$i<@seq;$i++){
        if (! exists $count{$i}){
            $count{$i}=0;
        }
        $count{$i}++ if $seq[$i]=~/^(n|N|-)$/;
    }
}
my %out;

$out{0}=0;
$out{20}=0;
$out{50}=0;
$out{70}=0;
for my $k (sort keys %count){
    $out{0}++ if $count{$k}==0;
    $out{20}++ if $count{$k}/scalar(keys %seq) < 0.2;
    $out{50}++ if $count{$k}/scalar(keys %seq) < 0.5;
    $out{70}++ if $count{$k}/scalar(keys %seq) < 0.7;
}

open (O,">$indir/00.consensus.info.txt")||die"$indir/00.consensus.info.txt\n";
print O "gene_id\tgene_length\traw_ind_number\tflt_cov_50_seq_ind_number\tflt_miss_0_sites\tflt_miss_20_sites\tflt_miss_50_sites\tflt_miss_70_sites\n";
die "$indir\n" if ((! $geneid) || (! $len[0]) || (! @in));
print O "$geneid\t$len[0]\t",scalar(@in),"\t",scalar(keys %seq),"\t$out{0}\t$out{20}\t$out{50}\t$out{70}\n";
close O;

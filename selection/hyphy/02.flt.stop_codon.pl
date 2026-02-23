use strict;
use warnings;

my $inputdir=shift or die "perl $0 inputdir\nThe */XX.fa-gb file should contained in the inputdir\n";

my @in=<$inputdir/*/*.fa-gb>;
for my $in (@in) {
    my ($len,%seq)=&read_fa("$in");
    next if $len<150;
    my $check0=0;
    my $check1=0;
    for my $k1 (sort keys %seq){
        my $seqk1=$seq{$k1};
        my $pep=&TranslateDNASeq($seqk1);
        if ($pep=~/\*$/){
            $check1++;
        }
        $pep=~s/\*$//;
        $check0++ if $pep=~/\*/;
    }
    next if $check0 > 0;
    $len=$len-3 if $check1>0;
    open(O,">$in.flt");
    for my $k1 (sort keys %seq){
        my $seqk1=$seq{$k1};
        my $newseq=substr($seqk1,0,$len);
        print O ">$k1\n$newseq\n";
    }
    close O;
}

sub TranslateDNASeq(){
    use Bio::Seq;
    (my $dna)=@_;
    my $seqobj=Bio::Seq->new(-seq =>$dna, -alphabet =>'dna');
    return $seqobj->translate()->seq();
}
sub read_fa{
    use Bio::SeqIO;
    my %r;
    my $l=0;
    my ($input)=@_;
    my $fa=Bio::SeqIO->new(-format=>"fasta",-file=>"$input");
    while (my $seq=$fa->next_seq) {
        my $id=$seq->id;
        my $seq=$seq->seq;
        $l=length($seq);
        $r{$id}=$seq;
    }
    return ($l,%r);
}
    

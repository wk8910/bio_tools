use strict;
use warnings;

my ($id_list,$bed_file,$indir,$outdir)=@ARGV;
die "perl $0 keep_id_list keep_pos_list input_dir output_dir\n" if (! $outdir);

my %idlist=&read_idlist("$id_list");
my %bed=&read_bed("$bed_file");
my %seq;
my %out;

my @consensus_fa=("$indir");
for my $consensus_fa (@consensus_fa){
    $consensus_fa=~/\/([^\/]+)\.fa.gz/ || die "$consensus_fa\n";
    my $id=$1;
    next if ! exists $idlist{$id};
    my ($gene,$seq)=("NA","");
    open (F,"zcat $consensus_fa | ");
    while (<F>) {
        chomp;
        if (/^>/){
            $_=~/^>(\w+)/;
            my $geneid=$1;
            if ($gene eq 'NA'){
	$gene=$geneid;
            }else{
	$seq{$id}{$gene}=$seq;
	$gene=$geneid;
	$seq="";
            }
        }else{
            $seq .= $_;
        }
    }
    close F;
    $seq{$id}{$gene}=$seq;
}

for my $ind (sort keys %seq){
    for my $k (sort keys %{$seq{$ind}}){
        my $seq=$seq{$ind}{$k};
        for my $k2 (sort keys %{$bed{$k}}){
            my $outseq;
            for my $s (sort{$a<=>$b} keys %{$bed{$k}{$k2}}){
	my $e=$bed{$k}{$k2}{$s};
	my $newseq=substr($seq,$s-1,$e-$s+1);
	$outseq .= $newseq;
            }
            $out{$k2}{$ind}=$outseq;
        }
    }
}
for my $k (sort keys %out){
    my $outdir_file="$outdir/$k";
    `mkdir -p $outdir_file` if (! -e "$outdir_file");
    #open (O,">$outdir_file/$k2.ind.fa");
    for my $k2 (sort keys %{$out{$k}}){
        open (O,">$outdir_file/$k2.ind.fa");
        print O ">$k2\n$out{$k}{$k2}\n";
        close O;
    }
    #close O;
}


sub read_idlist{
    my ($in)=@_;
    my %r;
    open (F,"$in")||die"$!";
    while (<F>) {
        chomp;
        my @a=split(/\s+/,$_);
        $r{$_}++;
    }
    close F;
    return %r;
}
sub read_bed{
    my ($in)=@_;
    my %r;
    open (F,"$in")||die"$!";
    while (<F>) {
        chomp;
        my @a=split(/\s+/,$_);
        my @b=split(/;/,$a[3]);
        for my $b (@b){
            $b=~/^(\d+)-(\d+)$/;
            $r{$a[0]}{$a[1]}{$1}=$2;
        }
    }
    close F;
    return %r;
}

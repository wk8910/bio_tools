use strict;
use warnings;

my %gff;

my @gff=@ARGV;
die "perl $0 gff1 gff2 gff3 ...\nEach gff file should containd the gene, CDS, exon and mRNA lines\nThe row 9 should be 'ID=\\S+;parent=\\S+'\n" if (scalar(@gff) < 2);

my $linenum=0;
for my $gffinfile (@gff){
    my $geneid;
    my $transid;
    
    open (F,"$gffinfile");
    while (<F>) {
        chomp;
        $linenum++;
        my @a=split(/\t/,$_);
        $a[1]='EVM';
        $a[0]=~/scaffold(\d+)/;
        my $chr=$1;
        if ($a[2] eq 'gene'){
            $a[8]=~/ID=(\S+)/;
            $geneid=$1;
            $gff{$chr}{$a[6]}{$geneid}{start}=$a[3];
            $gff{$chr}{$a[6]}{$geneid}{end}=$a[4];
        }
        $gff{$chr}{$a[6]}{$geneid}{gff} .= "$_\n";
    }
    close F;
}

my %out;
for my $k1 (sort{$a<=>$b} keys %gff){
    for my $k2 (sort keys %{$gff{$k1}}){
        my @k3=sort{$gff{$k1}{$k2}{$a}{start} <=> $gff{$k1}{$k2}{$b}{start}} keys %{$gff{$k1}{$k2}};
        my ($oldk,$oldstart,$oldend)=(0,0,0);

        for my $k3 (@k3){
            my ($newk,$newstart,$newend)=($k3,$gff{$k1}{$k2}{$k3}{start},$gff{$k1}{$k2}{$k3}{end});
            if ($oldstart==0 && $oldend==0){
	($oldk,$oldstart,$oldend)=($newk,$newstart,$newend);
            }elsif ($oldend > $newstart){
	my $oldlen=$oldend-$oldstart+1;
	my $newlen=$newend-$newstart+1;
	my $overlap=$oldend-$newstart+1;
	#if ($overlap/$oldlen >= 0.5 || $overlap/$newlen>=0.5){
	if ($oldlen<$newlen){
	    ($oldk,$oldstart,$oldend)=($newk,$newstart,$newend);
	}
            }else{
	$out{$k1}{$oldstart}{$oldk}=$gff{$k1}{$k2}{$oldk}{gff};
	($oldk,$oldstart,$oldend)=($newk,$newstart,$newend);
            }
        }
        $out{$k1}{$oldstart}{$oldk}=$gff{$k1}{$k2}{$oldk}{gff};
    }
}
open (O,">$0.gff3");
for my $k1 (sort{$a<=>$b} keys %out){
    for my $k2 (sort {$a<=>$b} keys %{$out{$k1}}){
        for my $k3 (sort keys %{$out{$k1}{$k2}}){
            print O "$out{$k1}{$k2}{$k3}";
        }
    }
}
close O;

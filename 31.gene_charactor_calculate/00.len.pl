use strict;
use warnings;

my $in=shift or die "perl $0 input_gff3 XX_trans2gene.len.txt\nThe out put file should be ending with trans2gene.len.txt\n";
my $out=shift or die "perl $0 input_gff3 XX_trans2gene.len.txt\nThe out put file should be ending with trans2gene.len.txt\n";

open (O,">$out");
open (F,"$in");
while (<F>) {
    chomp;
    next if /^#/;
    my @a=split(/\s+/,$_);
    if ($a[2] eq 'mRNA'){
        my $len=$a[4]-$a[3]+1;
        $a[8]=~/ID=transcript:(\w+);Parent=gene:(\w+)/ or die "$_\n";
        print O "$2\t$1\t$len\n";
    }
}
close F;
close O;

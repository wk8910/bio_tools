use strict;
use warnings;

### filtering:
### 1. the number of sequence with coverage more than 50% of gene length were lager than 50% of all sequences
### 2. non-missing sites large than 150bp

open (F,"02.cds.info.pl.info.out");
while (<F>) {
    chomp;
    next if /^gene_id/;
    my @a=split(/\t/,$_);
    next if ! $a[3];
    next if ! $a[2];
    next if ! $a[4];
    next unless (($a[3]/$a[2]) > 0.5);
    next unless $a[4]>=150;
    print "perl 03.select.pl.extract.pl $a[0]\n";
}
close F;

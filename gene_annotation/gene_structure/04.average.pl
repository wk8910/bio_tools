use strict;
use warnings;

my %count;
my @in=<02.Gene.stat.pl.*txt>;
for my $in (@in){
    $in=~/02.Gene.stat.pl\.(\w+\.\w+)\.txt/ or die "$in\n";
    my $type=$1;
    open (F,"$in");
    while (<F>) {
        chomp;
        my @a=split(/\s+/,$_);
        $count{$a[0]}{$type}{num}++;
        $count{$a[0]}{$type}{len}+=$a[2];
    }
    close F;
}

print "Gene_set\tNumbers\tAverage_Gene_Length_(bp)\tAverage_CDS_Length_(bp)\tAverage_Exon_number\tAverage_Exon_Length_(bp)\tAverage_Intron_Length_(bp)\n";
my @k2=("mRNA.len","CDS.len","Exon.num","Exon.len","Intron.len");
for my $k (sort keys %count){
    my $k0="mRNA.len";
    print "$k\t$count{$k}{$k0}{num}\t";
    for my $k2 (@k2){
        print $count{$k}{$k2}{len}/$count{$k}{$k2}{num},"\t";
    }
    print "\n";
}

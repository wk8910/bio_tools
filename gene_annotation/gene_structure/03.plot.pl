use strict;
use warnings;

my %info;
$info{'0mRNA'}{file}="02.Gene.stat.pl.mRNA.len.txt";
$info{'1CDS'}{file}="02.Gene.stat.pl.CDS.len.txt";
$info{'2Exon'}{file}="02.Gene.stat.pl.Exon.len.txt";
$info{'3Intron'}{file}="02.Gene.stat.pl.Intron.len.txt";
$info{'4Exon_num'}{file}="02.Gene.stat.pl.Exon.num.txt";
$info{'0mRNA'}{id}="Gene length (bp)";
$info{'1CDS'}{id}="CDS length (bp)";
$info{'2Exon'}{id}="Exon length (bp)";
$info{'3Intron'}{id}="Intron length (bp)";
$info{'4Exon_num'}{id}="Exon number";
$info{'0mRNA'}{num}=100000;
$info{'1CDS'}{num}=10000;
$info{'2Exon'}{num}=1500;
$info{'3Intron'}{num}=10000;
$info{'4Exon_num'}{num}=50;

my @key=sort keys %info;
my @out;

open (O,">$0.R");
print O "library(ggplot2)\n";
print O "library(gridExtra)\n";

for my $key (@key){
    print O "read_$key = read.table(\"$info{$key}{file}\",header=F)\n";
    print O "plot_$key = ggplot(read_$key,aes(V3,col=V1))+geom_density()+xlim(0,$info{$key}{num})+xlab(\"$info{$key}{id}\")+ylab(\"Density\")+theme_bw()+theme(legend.position=\"none\")\n";
    my $plot_name="plot_$key";
    push @out,$plot_name;
}
print O "plot_legend_4Exon_num = ggplot(read_4Exon_num,aes(V3,col=V1))+geom_density()+xlim(0,$info{'4Exon_num'}{num})+xlab(\"$info{'4Exon_num'}{id}\")+ylab(\"Density\")+theme_bw()\n";
push @out,"plot_legend_4Exon_num";


print O "pdf(file=\"$0.pdf\",width=8,height=10)\n";
print O "grid.arrange(",join(",",@out),",ncol=2)\n";
print O "dev.off()\n";
close O;

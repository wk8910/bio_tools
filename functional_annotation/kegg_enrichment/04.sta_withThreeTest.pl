#! /usr/bin/env perl
use strict;
use warnings;

my ($target,$background,$out)=@ARGV;
my $rscript="Rscript";
my $min_ko=5; # min number of genes requred in a reported ko
die "Usage: $0 <target list> <background list> <output file prefix>\n" if(@ARGV<3);
$out="$out.koEnrichment";


my %kegg;
my %info;
my %gene;
open I,"< gene.path";
while (<I>) {
    chomp;
    my ($geneid,$ko,$info)=split(/\t/);
    $kegg{$ko}{$geneid}=1;
    $info{$ko}=$info;
    $gene{$geneid}=1;
}
close I;


my @genename;
open I,"< $background";
while (<I>) {
    chomp;
    /(\S+)$/;
    next if(!exists $gene{$1});
    push @genename,$1;
}
close I;

my %hash;
open I,"< $target";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($geneid)=@a;
    next if(!exists $gene{$geneid});
    $hash{$geneid}++;
}
close I;
my $background_number=@genename;
my $target_number= keys %hash;


my $number=0;
foreach my $ko(sort keys %kegg){
    my $ko_number=keys %{$kegg{$ko}};
    next if($ko_number<$min_ko);
    $number++;
}

# open O,"> $out";
# print O "ko\tbackground\ttarget\tko\toverlap\tpvalue\tinfo\n";
open R,"> $out.rscript";
print R "result=\"ko\tbackground\ttarget\tko\toverlap\tinfo\tc\tcfdr\tf\tffdr\th\thfdr\toverlapped_genes\"";
foreach my $ko(sort keys %kegg){
    my %selected;
    my $ko_number=keys %{$kegg{$ko}};
    next if($ko_number<$min_ko);
    my @genename;
    foreach my $geneid(keys %{$kegg{$ko}}){
        if(exists $hash{$geneid}){
            $selected{$geneid}++;
            push @genename,$geneid;
        }
    }
    my $overlap=keys %selected;
    my $percent1 = $overlap/$target_number;
    my $percent2 = $ko_number/$background_number;
    my $p=&hyper($background_number,$target_number,$ko_number,$overlap);
    my $a=$ko_number;
    my $b=$background_number-$ko_number;
    my $c=$overlap;
    my $d=$target_number-$overlap;
    my $x="$a,$b,$c,$d";
    my @y=($overlap-1,$a,$b,$target_number);
    my $y=join ",",@y;
    my $info=$info{$ko};
    my $genename= join ", ",@genename;
    my $prefix="$ko\t$background_number\t$target_number\t$ko_number\t$overlap\t$info";
    print R '
c=chisq.test(matrix(c('.$x.'),nrow=2))
cfdr=p.adjust(c$p.value,method="fdr",n='.$number.')
f=fisher.test(matrix(c('.$x.'),nrow=2),alternative="less")
ffdr=p.adjust(f$p.value,method="fdr",n='.$number.')
h=1-phyper('.$y.')
hfdr=p.adjust(h,method="fdr",n='.$number.')
line=paste("'.$prefix.'",c$p.value,cfdr,f$p.value,ffdr,h,hfdr,"'.$genename.'",sep="\t")
result=paste(result,line,sep="\n")
';
}
print R 'write.table(result,file="'.$out.'",,row.names=FALSE,col.names=FALSE,quote = FALSE)
';
close R;
`$rscript $out.rscript`;

sub hyper{
    my ($m,$t,$n,$r)=@_;
    my $var = 1;
    for(1..$n){
        $var *= ($m-$t-$n+$_)/($m-$n+$_);
    }
    my $P_value = 1 - $var;
    for(my $x=1;$x<=$r-1;$x++){
        $var *= ($t-$x+1)*($n-$x+1)/$x/($m-$t-$n+$x);
        $P_value -= $var;
    }
    if($P_value < 0){
        return 0;
    }
    return $P_value;
}

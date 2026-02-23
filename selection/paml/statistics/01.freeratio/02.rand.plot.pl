use strict;
use warnings;
use List::Util;

my %cluster;
my $in="All.freeratio.result.out";
open (F,"$in")||die"$!";
while (<F>){
    chomp;
    my @a=split(/\s+/,$_);
    next if /^cluster\s+/;
    next if $a[1]<150;
    $cluster{$a[2]}{$a[0]}{N}=$a[3];
    $cluster{$a[2]}{$a[0]}{S}=$a[4];
    $cluster{$a[2]}{$a[0]}{NdN}=$a[7];
    $cluster{$a[2]}{$a[0]}{SdS}=$a[8];
}
close F;

open (O,">$0.rand.150genes.10000times.out");
for my $k1 (sort keys %cluster){
    my @k2=keys %{$cluster{$k1}};
    my $i=0;
    while ($i<10000){
	@k2=List::Util::shuffle @k2;
	my ($allN,$allS,$allNdN,$allSdS);
	for (my $j=0;$j<150;$j++){
	    $allN += $cluster{$k1}{$k2[$j]}{N};
	    $allS += $cluster{$k1}{$k2[$j]}{S};
	    $allNdN += $cluster{$k1}{$k2[$j]}{NdN};
	    $allSdS += $cluster{$k1}{$k2[$j]}{SdS};
	}
	next if (($allN == 0) || ($allS == 0) || ($allSdS == 0));
	my $w=($allNdN/$allN)/($allSdS/$allS);
	print O "$k1\t$i\t$w\n";
	$i++;
    }
}
close O;
open (O,">$0.R");
print O "library(ggplot2)
a=read.table(\"$0.rand.150genes.10000times.out\")
pdf(file=\"$0.rand.150genes.10000times.out.pdf\",height=3,width=5)
ggplot(a,aes(V1,V3,col=V1))+geom_boxplot()+labs(x=\"Species\",y=\"Ka/Ks\")+theme(legend.title=element_blank())+theme(axis.text.x = element_text(angle = 270, hjust = 1))
dev.off()
";
close O;

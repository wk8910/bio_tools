use strict;
use warnings;

my $in="All.branch.chi2.out";
my $out="All.branch.chi2.fdr.out";
my $outr="$out.R";

my %p;
my %all;
my $linenum=0;
open (O,">$outr");
open (F,"$in");
while(<F>){
    chomp;
    my @a=split(/\s+/,$_);
    if (/^cluster/){
        print O "write.table(\"$_\tfdr\",file=\"$out\",append = FALSE,row.names=FALSE,col.names=FALSE,quote = FALSE)\n\n";
    }else{
        $all{$a[1]}{$linenum}=$_;
        $p{$a[1]}{$linenum}=$a[11];
        $linenum++;
    }
}
close F;

for my $sp (sort keys %p){
    my @p;
    my @pk=sort{$a<=>$b} keys %{$p{$sp}};
    for my $pk (@pk){
        push @p,$p{$sp}{$pk};
    }
    print O "pvalues = c(",join(",",@p),")\n";
    print O "qobj=p.adjust(pvalues,method='fdr')\n\n";#,n=length(pvalues))\n\n";
    my $j=0;
    for my $i (@pk){
	$j++;
        print O "line=paste(\"$all{$sp}{$i}\t\",qobj[$j])\n";
        print O "write.table(line,file=\"$out\",append = TRUE,row.names=FALSE,col.names=FALSE,quote = FALSE)\n\n";
    }
}
close O;

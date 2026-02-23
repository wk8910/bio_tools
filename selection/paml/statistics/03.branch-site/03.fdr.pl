use strict;
use warnings;

my $in="All.branchsite.result.chi2.out";
my $out="All.branchsite.result.chi2.fdr.out";
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
        $a[8]=$a[7];
        $a[7]="fdr";
        my $outline=join("\t",@a);
        print O "write.table(\"$outline\",file=\"$out\",append = FALSE,row.names=FALSE,col.names=FALSE,quote = FALSE)\n\n";
    }else{
        $all{$a[1]}{$linenum}=$_;
        $p{$a[1]}{$linenum}=$a[6];
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
        my @outline=split(/\t/,$all{$sp}{$i});
        my $last=pop @outline;
        my $first=join("\t",@outline);
        print O "line=paste(\"$first\t\",qobj[$j],\"$last\")\n";
        print O "write.table(line,file=\"$out\",append = TRUE,row.names=FALSE,col.names=FALSE,quote = FALSE)\n\n";
    }
}
close O;

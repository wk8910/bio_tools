#! /usr/bin/env perl
use strict;
use warnings;

my ($list1,$list2)=@ARGV;
die "Usage: $0 <target list> <background>\n" if(@ARGV<2);
my $oid="$list1.$list2";

my $table="Gene2GoID.table";
my $obo="gene_ontology.obo";

my $R_bin="Rscript";

my $out="result.$oid.txt";
open(T,"> $out")||die"$out $!\n";
print T "GO\tType\tFunction\tfisher\tf.fdr\tchi\tc.fdr\thyper\th.fdr\tlist1InGO\tlist1OutGO\tlist1Percent\tlist2InGO\tlist2OutGO\tlist2Percent\tPercentDiff";
close T;
my $Rscript="runR.$oid.r";

my %GOname=&readobo($obo);

my %GO1=&readlist($list1,$table);
my $num1=num($list1,$table);
my %GO2=&readlist($list2,$table);
my $num2=num($list2,$table);
print "$num1\t$num2\n";

my $go_number=&read_table($table);
print "go number: $go_number\n";

open(R,"> $Rscript");
print R "enrichment_result=\"\";";
foreach my $go(sort keys %GOname){
    next unless(exists $GO1{$go} || exists $GO2{$go});
    my $a=keys %{$GO1{$go}}; 
    #next if($a<5);
    my $b=$num1-$a;
    my $p1=$a/($a+$b);
    my $c=keys %{$GO2{$go}};
    #next if($c<5);
    my $d=$num2-$c;
    my $p2=$c/($c+$d);
    my $diff=$p1-$p2;
    #next unless($a > 5 || $c > 5);
    print R "
data_matrix=matrix(c($a,$b,$c,$d),ncol=2);

chi_p=chisq.test(data_matrix);
chi_fdr=p.adjust(chi_p\$p.value,method='fdr',$go_number);

fisher_p=fisher.test(data_matrix);
fisher_fdr=p.adjust(fisher_p\$p.value,method='fdr',$go_number);

hyper_p=1-phyper($a-1,$c,$num2-$c,$num1)
hyper_fdr=p.adjust(hyper_p,method='fdr',$go_number);

line=paste(\"$go\t$GOname{$go}{namespace}\t$GOname{$go}{name}\t\",fisher_p\$p.value,\"\t\",fisher_fdr,\"\t\",chi_p\$p.value,\"\t\",chi_fdr,\"\t\",hyper_p,\"\t\",hyper_fdr,\"\t$a\t$b\t$p1\t$c\t$d\t$p2\t$diff\");
# line;
# write.table(line,file=\"$out\",append = TRUE,row.names=FALSE,col.names=FALSE,quote = FALSE);
enrichment_result=paste(enrichment_result,line,sep=\"\n\");
";
}
print R "write.table(enrichment_result,file=\"$out\",append = TRUE,row.names=FALSE,col.names=FALSE,quote = FALSE);\n";
close R;
`$R_bin $Rscript`;

sub num{
    my ($file,$table)=@_;
    open(F,$table)||die "$!";
    my $number=0;
    my %test;
    while(<F>){
        chomp;
        next if(/^\s*$/);
        my @a=split("\t",$_);
        $test{$a[0]}++;
    }
    close F;
    open(G,"< $file");
    while (<G>) {
        chomp;
        my @a=split(/\s+/);
        next if(!exists $test{$a[0]});
        $number++;
    }
    close G;
    return $number;
}

sub readlist{
    my ($file,$table)=@_;
    open(G,"< $file");
    my %go;
    while (<G>) {
        chomp;
        my @a=split(/\s+/);
        $go{$a[0]}="TRUE";
    }
    close G;
    my %r;
    open(F,$table)||die "$table $!";
    while(<F>){
        chomp;
        next if(/^\s*$/);
        my @a=split("\t",$_);
        next if(!exists $go{$a[0]});
        for(my $i=1;$i<@a;$i++){
            if($a[$i]=~m/GO/){
	$r{$a[$i]}{$a[0]}++;
            }
        }
    }
    close(F);
    return %r;
}

sub readobo{
  my $file=shift;
  my %r;
  open(F,$file)||die "$file $!";
  while(<F>){
    chomp;
    if(/^\[Term\]$/){
      my $idline=<F>;
      chomp $idline;
      $idline=~s/id: //g;
      
      my $nameline=<F>;
      chomp $nameline;
      $nameline=~s/name: //g;
      
      my $namespaceline=<F>;
      chomp $namespaceline;
      $namespaceline=~s/namespace: //g;
      $r{$idline}{name}=$nameline;
      $r{$idline}{namespace}=$namespaceline;
  }
}
  close(F);
  #print scalar(keys %r);
  #die;
  return %r;
}

sub read_table{
    my $table=shift;
    open(I,"< $table") || die "Cannot open $table";
    my %go_term;
    while(<I>){
	chomp;
	my @a=split(/\s+/);
	for(my $i=1;$i<@a;$i++){
	    $go_term{$a[$i]}++;
	}
    }
    close I;
    my $go_number=keys %go_term;
    return($go_number);
}

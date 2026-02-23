#! /usr/bin/env perl
use strict;
use warnings;

my ($list1,$list2,$out_prefix)=@ARGV;

die "Usage: $0 <list1> <list2> <out_prefix>\n" if(@ARGV<3);

my $map="kegg.map";
my $ko ="query.ko";

my $Rscript="runR.$out_prefix.r";
my $outfile="result.$out_prefix.txt";
open(O,"> $outfile");
print O "ko\tinfo\tx-2\tfdr\tFisher\tfdr\tlist1InGO\tlist1OutGO\tlist1Percent\tlist2InGO\tlist2OutGO\tlist2Percent\tPercentDiff\n";
close O;

my %list1=&readlist($list1);
my %list2=&readlist($list2);

my %kegg=&readmap($map);
my %query=&readko($ko);

my %reverse_query;
foreach my $gene(keys %query){
    my $kn=$query{$gene};
    $reverse_query{$kn}{$gene}++;
}

my $num_list1=&num(\%list1,\%query);
my $num_list2=&num(\%list2,\%query);

open(R,"> $Rscript");
foreach my $ko(sort keys %kegg){
    my $info=$kegg{$ko}{info};
    my $list1_in=0;
    my $list2_in=0;

    foreach my $kn(keys %{$kegg{$ko}{kn}}){
        my @id=keys %{$reverse_query{$kn}};
        foreach my $id(@id){
            if(exists $list1{$id}){
	$list1_in++;
            }
            if(exists $list2{$id}){
	$list2_in++;
            }
        }
    }
    my $list1_out=$num_list1 - $list1_in;
    my $list2_out=$num_list2 - $list2_in;

    my $p1=$list1_in/$num_list1;
    my $p2=$list2_in/$num_list2;

    my $diff=$p1-$p2;

    #print "$list1_in\t$list1_out\t$list2_in\t$list2_out\t$info\n";
    print R "
a=matrix(c($list1_in,$list1_out,$list2_in,$list2_out),ncol=2);
#a;
b=chisq.test(a);
c=fisher.test(a);
bfdr=p.adjust(b\$p.value,method='fdr',337);
cfdr=p.adjust(c\$p.value,method='fdr',337);
line=paste(\"$ko\t$info\t\",b\$p.value,\"\t\",bfdr,\"\t\",c\$p.value,\"\t\",cfdr,\"\t$list1_in\t$list1_out\t$p1\t$list2_in\t$list2_out\t$p2\t$diff\");
#line;
write.table(line,file=\"$outfile\",append = TRUE,row.names=FALSE,col.names=FALSE,quote = FALSE);
";
}
close R;
`Rscript $Rscript`;

sub num{
    my ($list,$query)=@_;
    my $number=0;
    foreach my $gene(keys %{$list}){
        next unless(exists $query->{$gene});
        $number++;
    }
    return($number);
}

sub readlist{
    my $file=shift;
    my %hash;
    open(I,"< $file");
    while (<I>) {
        chomp;
        my @a=split(/\s+/);
        next if(!$a[0]);
        $hash{$a[0]}++;
    }
    close I;
    return(%hash);
}

sub readmap{
    my $file=shift;
    my %hash;
    open(I,"< $file");
    while (<I>) {
        chomp;
        my @a=split(/;/);
        my $ko=$a[0];
        my $info=$a[1];
        my @kn=split(/\s+/,$a[2]);
        $hash{$ko}{info}=$info;
        foreach my $kn(@kn){
            $hash{$ko}{kn}{$kn}=1;
        }
    }
    close I;
    return(%hash);
}

sub readko{
    my $file=shift;
    my %hash;
    open(I,"< $file");
    while (<I>) {
        chomp;
        my @a=split(/\s+/);
        next unless(@a==2);
        $hash{$a[0]}=$a[1];
    }
    close I;
    return(%hash);
}

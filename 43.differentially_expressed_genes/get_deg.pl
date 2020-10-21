#! /usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my @control;
my @experimental;
GetOptions(
    "control|c:s" => \@control,
    "experimental|e:s" => \@experimental,
) or die "Usage: $0 -c control1 -c control2 -e exp1 -e exp2\n";

if(!@control || !@experimental){
    die "Usage: $0 -c control1 -c control2 -e exp1 -e exp2\n";
}


my $sample_lst="sample.lst";
my $reads_count="all.reads_count";
my $outdir="process";
`mkdir $outdir` if(!-e $outdir);
my $left=join "_",@control;
my $right=join "_",@experimental;
my $out_prefix="${left}_VS_${right}";
print "out file: $outdir/$out_prefix\n";

my %group;
foreach my $sample(@control){
    $group{$sample}=1;
}
foreach my $sample(@experimental){
    $group{$sample}=2;
}

my %id;
open I,"< $sample_lst";
while (<I>) {
    chomp;
    my ($id,$group)=split(/\s+/);
    if(exists $group{$group}){
        if($group{$group} == 1){
            $id{$id}=1;
        }
        elsif ($group{$group} == 2) {
            $id{$id}=2;
        }
    }
}
close I;

# foreach my $id(sort keys %id){
#     print "$id\t$id{$id}\n";
# }

open I,"< $reads_count";
open O,"> $outdir/$out_prefix.count";
my $head=<I>;
chomp $head;
my @head=split(/\s+/,$head);
my (@new_head,@left,@right);
for(my $i=1;$i<@head;$i++){
    my $id=$head[$i];
    if(exists $id{$id}){
        if($id{$id}==1){
            push @left,$head[$i];
        }
        elsif ($id{$id}==2) {
            push @right,$head[$i];
        }
    }
}
@new_head=(@left,@right);
my $new_head=join "\t",@new_head;
print O "\t$new_head\n";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my @control;
    my @experimental;
    for(my $i=1;$i<@a;$i++){
        my $id=$head[$i];
        if(exists $id{$id}){
            if($id{$id}==1){
	push @control,$a[$i];
            }
            elsif ($id{$id}==2) {
	push @experimental,$a[$i];
            }
        }
    }
    my @line=($a[0],@control,@experimental);
    my $line=join "\t",@line;
    print O "$line\n";
}
close I;
close O;

my @factor;
foreach my $x(@left){
    push @factor,1;
}
foreach my $y(@right){
    push @factor,2;
}
my $factor=join ",",@factor;

open R,"> $outdir/$out_prefix.Rscript";
print R '
library("edgeR")
x=read.table("'."$outdir/$out_prefix.count".'",header=T)
group=factor(c('.$factor.'))
y <- DGEList(counts=x,group=group)
y <- calcNormFactors(y)
y <- estimateCommonDisp(y)
y <- estimateTagwiseDisp(y)
et <- exactTest(y)
et$table$fdr=p.adjust(et$table$PValue,method="fdr")
write.table(et$table,file="'."$outdir/$out_prefix.pvalue".'",quote=F,sep="\t")
';
close R;
`Rscript $outdir/$out_prefix.Rscript`;

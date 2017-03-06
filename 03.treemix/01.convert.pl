#! /usr/bin/env perl
use strict;
use warnings;

my $vcf="merge.vcf.gz";
my $out="merge.gz";
my $popList="pop.lst";

=cut
Sample of poplist:
ind1 pop1
ind2 pop1
ind3 pop2
=cut

my %sample2pop;
my %popList;
open(I,"< $popList");
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    $sample2pop{$a[0]}=$a[1];
    $popList{$a[1]}++;
}
close I;
my @popList=sort keys %popList;

open(O,"| gzip - > $out");
print O join " ",@popList,"\n";
my @head;
open(I,"zcat $vcf |");
while (<I>) {
    chomp;
    next if(/^##/);
    if(/^#/){
        @head=split(/\s+/);
        last;
    }
}

while (<I>) {
    chomp;
    # next if(/\.\/\./);
    my @a=split(/\s+/);
    my %popSta;
    for(my $i=9;$i<@a;$i++){
        my $sample=$head[$i];
        my $pop=$sample2pop{$sample};
        next if($a[$i]=~/\.\/\./);
        $a[$i]=~/(\d)\/(\d)/;
        my ($a,$b)=($1,$2);
        if(!exists $popSta{$pop}){
            $popSta{$pop}{0}=0;
            $popSta{$pop}{1}=0;
        }
        $popSta{$pop}{$a}++;
        $popSta{$pop}{$b}++;
    }
    my @line;
    my $light=1;
    foreach my $pop(@popList){
        if(!exists $popSta{$pop}){
            $light=0;
            last;
        }
        my $element=$popSta{$pop}{0}.",".$popSta{$pop}{1};
        push @line,$element;
    }
    next if($light==0);
    # print STDERR "@line\n";
    print O join " ",@line,"\n";
}
close I;
close O;

#! /usr/bin/perl
use strict;
use warnings;

my ($vcf,$list)=@ARGV;
# $list is like this:
=cut
sample1    population1
sample2    population1
sample3    out
=cut
# the sample name should be same as which in vcf file.
my $usage="Usage: perl convert_vcf_to_dadi_input.pl <vcf file> <list file>\n";

die "$usage" if(@ARGV<2);

my %list=&read_list($list);

if($vcf=~/\.gz$/){
    open(I,"zcat $vcf |") || die "Cannot open $vcf!\n";
}
else{
    open(I,"< $vcf") || die "Cannot open $vcf!\n";
}

my @head;
my %pop;
while(<I>){
    chomp;
    next if(/^##/);
    if(/^#/){
        @head=split(/\s+/);
        for(my $i=9;$i<@head;$i++){
            my $id=$head[$i];
            next if(!exists $list{$id});
            my $pop=$list{$id};
            $pop{$pop}=1;
        }
        last;
    }
}

my @pop;
foreach my $pop(sort keys %pop){
    next if($pop eq "out");
    push @pop,"$pop";
}
my @first_line=("Ref","OUT","Allele1",@pop,"Allele2",@pop,"Gene","Postion");

open(O,"> $vcf.data") || die "Cannot create $vcf.data\n";
print O join "\t",@first_line,"\n";

while(<I>){
    my @a=split(/\s+/);
    my ($chr,$pos,$ref,$alt)=($a[0],$a[1],$a[3],$a[4]);
    my %population;
    next if(length($ref)>1 || length($alt)>1);

    foreach my $pop(@pop){
        $population{$pop}{ref}=0;
        $population{$pop}{alt}=0;
    }

    for(my $i=9;$i<@a;$i++){
        my $id=$head[$i];
        next if(!exists $list{$id});
        my $geno=$a[$i];
        # next if($geno=~/^\.\:/);
        next unless($geno=~/^(.)[|\/](.)/);
        my ($a,$b)=($1,$2);
        next if($a eq "." || $b eq ".");
        my $x=$a+$b;
        my $pop=$list{$id};
        $population{$pop}{ref}+=2-$x;
        $population{$pop}{alt}+=$x;
    }

    my @Allele1;
    my @Allele2;
    foreach my $pop(@pop){
        push @Allele1,$population{$pop}{ref};
        push @Allele2,$population{$pop}{alt};
    }

    my $first="N".$ref."N";
    my $second="N".$ref."N";
    if(exists $population{out}){
        if($population{out}{alt}>=$population{out}{ref}){
            $second="N".$alt."N";
        }
    }
    my @line=($first,$second,$ref,@Allele1,$alt,@Allele2,$chr,$pos);
    print O join "\t",@line,"\n";
}
close I;
close O;

sub read_list{
    my $list=shift;
    my %list;
    open(IN,"< $list") || die "Cannot open $list!\n";
    while (<IN>) {
        chomp;
        next if(/^\#/);
        my @a=split(/\s+/);
        next if(@a==1);
        $list{$a[0]}=$a[1];
    }
    close IN;
    return(%list);
}

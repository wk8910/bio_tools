#! /usr/bin/env perl
use warnings;

my $ref_vcf="/home/share/user/user101/projects/yangshu.version2/06.three_pop.beagle/pda_e.lst.vcf.gz";
my $new_vcf=shift;
my $out_vcf=$new_vcf.".corrected.vcf";

my %hash;
open I,"zcat $ref_vcf |";
while(<I>){
    chomp;
    next if(/^#/);
    my @a=split(/\s+/);
    my ($chr,$pos,$ref,$alt)=($a[0],$a[1],$a[3],$a[4]);
    $chr=&replace($chr);
    $hash{$chr}{$pos}=$ref;
}
close I;

open I,"< $new_vcf";
open O,"> $out_vcf";
my $control=0;
while(<I>){
    chomp;
    if(/^#/){
        print O "$_\n";
        next;
    }
    my @a=split(/\s+/);
    my ($chr,$pos,$ref,$alt)=($a[0],$a[1],$a[3],$a[4]);
    $chr=&replace($chr);
    if($ref ne $hash{$chr}{$pos}){
        for(my $i=9;$i<@a;$i++){
            if($a[$i]=~/^([01][\/\|][10])/){
		$content=$1;
		$content=~tr/01/10/;
		$a[$i]=$content;
	    }
	}
	$a[4]=$a[3];
	$a[3]=$hash{$chr}{$pos};
    }
    if($a[4] eq "."){
	$a[4]=$a[3];
    }
    print O join "\t",@a,"\n";
    # last if($control++>1000);
}
close I;
close O;


sub replace{
    my $temp_str=shift;
    if($temp_str=~/^Chr/){
        $temp_str=~s/Chr//;
    }
    $temp_str=~s/^0*//;
    return($temp_str);
}

#! /usr/bin/env perl
use strict;
use warnings;

my $vcf="snpAndNonSnp.vcf.gz";

my %sta;
open I,"zcat $vcf |";
my @head;
my $control=0;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    if(/^##/){
        next;
    }
    elsif(/^#/){
        @head=@a;
    }
    else{
	for(my $i=9;$i<@a;$i++){
            my $id=$head[$i];
	    next if($a[$i]=~/\.\/\./);
	    $sta{$id}{all}++;
	    if($a[$i]=~/0\/1/){
		$sta{$id}{hete}++;
	    }
	    elsif($a[$i]=~/1\/1/){
		$sta{$id}{homo}++;
	    }
	}
    }
    # last if($control++>10000);
}
close I;

open O,"> $0.txt";
print O "id\tall\thete\thomo\n";
foreach my $id(sort keys %sta){
    my $all=$sta{$id}{all};
    my $hete=$sta{$id}{hete};
    my $homo=$sta{$id}{homo};
    print O "$id\t$all\t$hete\t$homo\n";
}
close O;

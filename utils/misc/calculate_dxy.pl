#! /usr/bin/env perl
use strict;
use warnings;

my $vcf="snp.vcf.gz";
my $pop_lst="keep.txt";
my $window_len=50000;

my %pop;
open I,"< $pop_lst";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($id,$pop)=@a;
    $pop{$id}=$pop;
}
close I;

open I,"zcat $vcf |";
my $head;     # lines with one #
while(<I>){
    chomp;
    if(/^##/){
        next;
    }
    if(/^#/){
        $head=$_;
        last;
    }
}

my @head=split(/\s+/,$head);

my %result;
my $control=0;
while(<I>){
    chomp;
    s/\|/\//g;
    my @a=split(/\s+/);
    my ($chr,$pos)=($a[0],$a[1]);
    my $window=int($pos/$window_len)*$window_len+($window_len/2);
    my %sta;
    for(my $i=9;$i<@a;$i++){
	my $id=$head[$i];
	next if(!exists $pop{$id});
	my $species=$pop{$id};
	next unless($a[$i]=~/(\d)\/(\d)/);
	my ($left,$right)=($1,$2);
	my $alt=$left+$right;
	my $ref=2-$alt;
	$sta{$species}{alt}+=$alt;
	$sta{$species}{ref}+=$ref;
    }
    my %dxy;
    my @species=sort keys %sta;
    for(my $i=0;$i<@species;$i++){
	for(my $j=$i+1;$j<@species;$j++){
	    my $a_alt=$sta{$species[$i]}{alt};
	    my $a_ref=$sta{$species[$i]}{ref};
	    my $b_alt=$sta{$species[$j]}{alt};
	    my $b_ref=$sta{$species[$j]}{ref};

	    my $dxy=($a_alt*$b_ref + $a_ref*$b_alt)/(($a_alt+$a_ref) * ($b_alt+$b_ref));

	    # print "$a_alt\t$a_ref\t$b_alt\t$b_ref\t$dxy\n";

	    my $pair=$species[$i]."-".$species[$j];
	    $result{$pair}{$chr}{$window}{dxy}+=$dxy;
	    $result{$pair}{$chr}{$window}{nsite}++;
	}
    }
    # last if($control++>10000);
}
close I;

foreach my $pair(sort keys %result){
    open O,"> $vcf.$pair.dxy";
    foreach my $chr(sort keys %{$result{$pair}}){
	foreach my $window(sort {$a<=>$b} keys %{$result{$pair}{$chr}}){
	    my $dxy=$result{$pair}{$chr}{$window}{dxy};
	    my $nsite=$result{$pair}{$chr}{$window}{nsite};
	    next if($nsite == 0);
	    my $dxy_mean=$dxy/$nsite;
	    print O "$chr\t$window\t$dxy\t$nsite\t$dxy_mean\n";
	}
    }
    close O;
}

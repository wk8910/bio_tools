#! /usr/bin/env perl
use strict;
use warnings;

open I,"zcat 02.convert.pl.site.gz |";
<I>;
my $window_size = 50000;
my %hash;
my $control=0;
while(my $line=<I>){
    chomp $line;
    $line=uc($line);
    next if($line=~/N/);
    my @a=split /\s+/,$line;
    my $chr = shift @a;
    my $pos = shift @a;
    my $index = int($pos/$window_size);
    my $rand = rand(1);
    if($a[3] eq "W"){
	if($rand < 0.5){
	    $a[3] = "A";
	}
	else{
	    $a[3] = "T";
	}
    }
    elsif($a[3] eq "S"){
	if($rand < 0.5){
	    $a[3] = "C";
	}
	else{
	    $a[3] = "G";
	}
    }
    elsif($a[3] eq "K"){
	if($rand < 0.5){
	    $a[3] = "T";
	}
	else{
	    $a[3] = "G";
	}
    }
    elsif($a[3] eq "M"){
	if($rand < 0.5){
	    $a[3] = "A";
	}
	else{
	    $a[3] = "C";
	}
    }
    elsif($a[3] eq "Y"){
	if($rand < 0.5){
	    $a[3] = "C";
	}
	else{
	    $a[3] = "T";
	}
    }
    elsif($a[3] eq "R"){
	if($rand < 0.5){
	    $a[3] = "A";
	}
	else{
	    $a[3] = "G";
	}
    }

    $hash{$chr}{$index}{site}++;
    for(my $i=0;$i<@a;$i++){
	my $left=$a[$i];
	for(my $j=$i+1;$j<@a;$j++){
	    my $right=$a[$j];
	    my $com = $i."-".$j;
	    if(!exists $hash{$chr}{$index}{com}{$com}){
		$hash{$chr}{$index}{com}{$com}=0;
	    }
	    if($left ne $right){
		$hash{$chr}{$index}{com}{$com}++;
	    }
	}
    }
    # last if($control++ > 100000);
}
close I;

open O,"> $0.sta";
foreach my $chr(sort keys %hash){
    foreach my $index(sort {$a<=>$b} keys %{$hash{$chr}}){
	my $site = $hash{$chr}{$index}{site};
	my @line=($chr,$index,$site);
	for(my $i=0;$i<6;$i++){
	    for(my $j=$i+1;$j<6;$j++){
		my $com = $i."-".$j;
		my $number = 0;
		if(exists $hash{$chr}{$index}{com}{$com}){
		    $number = $hash{$chr}{$index}{com}{$com};
		}
		push @line,$number;
	    }
	}
	print O join "\t",@line,"\n";
    }
}
close O;

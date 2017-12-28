#! /usr/bin/env perl
use strict;
use warnings;

my $in="gac.maf.lst.gz";
my $out="$0.sta";
my $window_size=100000;

open I,"zcat $in |";
my $head=<I>;
my @head=split(/\s+/,$head);
my %hash;
my $control=0;
my @firstline=("chr","window","informative_site");
for(my $i=2;$i<@head;$i++){
    for(my $j=$i+1;$j<@head;$j++){
        my $com=$head[$i]."_".$head[$j];
        push @firstline,$com;
    }
}

while(my $line=<I>){
    chomp $line;
    $line=uc($line);
    next if($line=~/N/);
    my @a=split /\s+/,$line;
    my $chr = $a[0];
    my $pos = $a[1];
    my $index = int($pos/$window_size)*$window_size;
    my $light=1;
    for(my $i=2;$i<@a;$i++){
        $a[$i]=&split_degenerate_base($a[$i]);
        if($a[$i]!~/[ATCG]/){
            $light=0;
        }
    }
    next if($light==0);

    $hash{$chr}{$index}{site}++;
    for(my $i=2;$i<@a;$i++){
        my $left=$a[$i];
        for(my $j=$i+1;$j<@a;$j++){
            my $right=$a[$j];
            my $com = $head[$i]."_".$head[$j];
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


open O,"> $out";
my $firstline=join "\t",@firstline;
print O "$firstline\n";
foreach my $chr(sort keys %hash){
    foreach my $index(sort {$a<=>$b} keys %{$hash{$chr}}){
        my $site = $hash{$chr}{$index}{site};
        my @line=($chr,$index,$site);
        for(my $i=3;$i<@firstline;$i++){
            my $com = $firstline[$i];
            my $number = 0;
            if(exists $hash{$chr}{$index}{com}{$com}){
	$number = $hash{$chr}{$index}{com}{$com};
            }
            push @line,$number;
        }
        my $line = join "\t",@line;
        print O "$line\n";
    }
}
close O;

sub split_degenerate_base{
    my $base=shift;
    $base=uc($base);
    my $rand = rand(1);
    if($base eq "W"){
        if($rand < 0.5){
            $base = "A";
        }
        else{
            $base = "T";
        }
    }
    elsif($base eq "S"){
        if($rand < 0.5){
            $base = "C";
        }
        else{
            $base = "G";
        }
    }
    elsif($base eq "K"){
        if($rand < 0.5){
            $base = "T";
        }
        else{
            $base = "G";
        }
    }
    elsif($base eq "M"){
        if($rand < 0.5){
            $base = "A";
        }
        else{
            $base = "C";
        }
    }
    elsif($base eq "Y"){
        if($rand < 0.5){
            $base = "C";
        }
        else{
            $base = "T";
        }
    }
    elsif($base eq "R"){
        if($rand < 0.5){
            $base = "A";
        }
        else{
            $base = "G";
        }
    }
    return($base);
}

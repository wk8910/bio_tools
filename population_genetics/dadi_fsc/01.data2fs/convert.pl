#! /usr/bin/env perl
use strict;
use warnings;

my @pop=("pda_w","pro");
my @num=(22,48);

my ($data,$out)=@ARGV;
die "Usage: $0 <data> <out fs>\n" if(@ARGV<2);

open I,"< $data" or die "Cannot open $data\n";
open O,"> $out" or die "Cannot create $out\n";
my $head=<I>;
chomp $head;
my @head=split(/\s+/,$head);
if($head!~/Ref\s+OUT\s+Allele1.*Allele2.*Gene\s+Postion/){
    die "Please give dadi data file!\n";
}
my %data;
my $control = 0;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my $line=$_;
    my $ref=substr($a[0],1,1);
    my $out=substr($a[1],1,1);
    $out = $ref if($out eq "N");
    next if($out eq "N");
    my $status="ref";
    my %single_data;
    for(my $i=2;$i<@a;$i++){
	my $name = $head[$i];
	if($name =~/Allele/){
	    if($a[$i] ne $out){
		$status = "alt";
	    }
	    else{
		$status = "ref";
	    }
	    next;
	}
	last if($name=~/gene/);
	$single_data{$name}{$status}+=$a[$i];
    }
    my @count;
    for(my $i=0;$i<2;$i++){
	my $pop=$pop[$i];
	my $num=$num[$i];
	my $ref_count = ($single_data{$pop}{ref})?$single_data{$pop}{ref}:0;
	my $alt_count = ($single_data{$pop}{alt})?$single_data{$pop}{alt}:0;
	my $total = $ref_count+$alt_count;
	if($total == 0){
	    die "$line\n";
	}
	# $ref_count = int(($ref_count/$total)*$num+0.5);
	$alt_count = int(($alt_count/$total)*$num+0.5);
	push @count,$alt_count;
    }
    $data{$count[0]}{$count[1]}++;
    # last if($control++ >= 10);
}

print O ($num[0]+1)." ".($num[1]+1)." unfolded \"$pop[0]\" \"$pop[1]\"\n";
my @content;
for (my $i=0;$i<=$num[0];$i++){
    my @line;
    for (my $j=0;$j<=$num[1];$j++){
	my $count=0;
	if(exists $data{$i}{$j}){
	    $count = $data{$i}{$j};
	}
	push @line,$count;
	push @content,$count;
    }
    # print join "\t",@line,"\n";
}
print O join " ",@content,"\n";
close O;

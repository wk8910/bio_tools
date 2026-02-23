#! /usr/bin/env perl
use strict;
use warnings;

my $dir="bootstrap";
my $length_file="effective.len";
my $miu=1.26e-8;
my $gen_time=6;
my $param_file="$0.param"; # output file

open(I,"< $length_file");
my $length=<I>;
chomp $length;
print "$length\n";
close I;

my @bootstrap=<$dir/*>;
open L,"> $param_file" or die "Cannot create $param_file\n";
my $control=0;
foreach my $bootstrap(@bootstrap){
    my $result_dir="$bootstrap/output_dadi";
    my @files=<$result_dir/*>;

    my %hash;
    foreach my $file(@files){
	open(I,"< $file");
	while(<I>){
	    chomp;
	    next unless(/DADIOUTPUT/);
	    my $param_name=<I>;
	    my $param_value=<I>;
	    chomp $param_name;
	    chomp $param_value;
	    next if($param_value=~/--/ || $param_value=~/nan/);
	    my @params=split(/\s+/,$param_value);
	    $hash{$file}{likelihood}=$params[0];
	    $hash{$file}{param_value}=$param_value;
	    $hash{$file}{param_name}=$param_name;
	}
	close I;
    }



    foreach my $file(sort {$hash{$b}{likelihood} <=> $hash{$a}{likelihood}} keys %hash){
	my $param_name=$hash{$file}{param_name};
	my $param_value=$hash{$file}{param_value};
	my @names=split(/\s+/,$param_name);
	my @params=split(/\s+/,$param_value);
	my @head;
	my @content;
	push @head,"file_name";
	push @content,$file;
	
	push @head,"likelihood";
	push @content,$params[0];
	
	my $theta=$params[1]/$length;
	push @head,"theta";
	push @content,$theta;
	my $nref=$theta/(4*$miu);
	push @head,"Nref";
	push @content,$nref;
	
	for(my $i=2;$i<@names;$i++){
	    $names[$i]=~/^(\w)\./;
	    my $type=$1;
	    my $param=$params[$i];
	    if($type eq "N"){
		$param = $param * $nref;
	    }
	    elsif($type eq "T"){
		$param = 2 * $nref * $param * $gen_time;
	    }
	    elsif($type eq "M"){
		# $param = 2 * $nref * $param;
		$param = $param / (2 * $nref);
	    }
	    push @head,$names[$i];
	    push @content,$param;
	}
	if($control == 0){
	    print L join "\t",@head,"\n";
	}
	print L join "\t",@content,"\n";
	last;
    }
    $control++;
}
close L;

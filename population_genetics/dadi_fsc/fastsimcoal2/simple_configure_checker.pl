#! /usr/bin/env perl
# This script is used to check if the tpl and est files are correct.
# Author: Kun Wang
# Date: 2016/01/13

use strict;
use warnings;

my ($tpl,$est)=@ARGV;
if(@ARGV != 2){
    $tpl="model.tpl";
    $est="model.est";
}

if(!-e $tpl || !-e $est){
    die "Usage: $0 <tpl file> <est file>\n";
}

my %est_params=&check_est($est);
my %tpl_params=&check_tpl($tpl);

my @simple_params = sort keys %est_params;
for(my $i=0;$i<@simple_params;$i++){
    for(my $j=$i+1;$j<@simple_params;$j++){
	my $left=$simple_params[$i];
	my $right=$simple_params[$j];
	if($left=~/$right/ || $right=~/$left/){
	    print STDERR "ERROR: $left and $right are confused! The name of params should not be overlapped!\n";
	}
    }
}

foreach my $params(sort keys %est_params){
    my $light=$est_params{$params};
    # print "$params\t$light\n";
    next if($light==0);
    if(!exists $tpl_params{$params}){
	print STDERR "WARNINGS: $params defined, but not used!\n";
    }
}

foreach my $params(sort keys %tpl_params){
    # print "$params\n";
    if(!exists $est_params{$params}){
	print STDERR "ERROR: $params not defined in tpl file: $tpl!\n";
    }
}

sub check_tpl{
    my $file=shift;
    my %params;
    open(I,"< $file") or die "Cannot read $file!\n";
    <I>;
    my $first_line=<I>;
    my $sample_num;
    if($first_line=~/^(\d+)\s+/){
	$sample_num=$1;
    }
    else{
	die "FATAL ERROR: The second line is not start with a number, $file is not a tpl file!\n";
    }
    <I>;
    my $real_num=0;
    while(<I>){
	chomp;
	next if(/^\s*$/);
	if(/^\/\//){
	    last;
	}
	else{
	    /^(\S+)/;
	    my $x=$1;
	    if(&check_param($x)==1){
		$params{$x}=1;
	    }
	}
	$real_num++;
    }
    if($real_num != $sample_num){
	print STDERR "ERROR: samples size is $sample_num, but there are $real_num populations!\n";
    }
    $real_num=0;
    while(<I>){
	chomp;
	if(/^\/\//){
	    last;
	}
	else{
	    /^(\S+)/;
	    my $x=$1;
	    if(&check_param($x)==1){
		$params{$x}=1;
	    }
	}	
	$real_num++;
    }
    if($real_num != $sample_num){
	print STDERR "ERROR: samples size is $sample_num, but there are $real_num population size!\n";
    }    
    $real_num=0;
    while(<I>){
	chomp;
	if(/^\/\//){
	    last;
	}
	else{
	    /^(\S+)/;
	    my $x=$1;
	    if(&check_param($x)==1){
		$params{$x}=1;
	    }
	}	
	$real_num++;
    }
    if($real_num != $sample_num){
	print STDERR "ERROR: samples size is $sample_num, but there are $real_num growth rate!\n";
    }
    my $mig_line=<I>;
    my $mig_num=0;
    if($mig_line=~/^(\d+)/){
	$mig_num=$1;
    }
    else{
	die "FATAL ERROR: The fifth section should be migration matrix, but not detected!\n";
    }
    if($mig_num>0){
	<I>;
	for(my $i=$mig_num;$i>0;$i--){
	    $real_num=0;
	    while(<I>){
		if(/^\/\//){
		    if($i>1 && /historical/){
			die "FATAL ERROR: $mig_num migration matrixes are expected, but $i matrixes were missing!\n";
		    }
		    elsif($i==1 && !/historical/){
			die "FATAL ERROR: $mig_num migration matrixes are expected, but there are more matrixes here!\n";
		    }
		    last;
		}
		else{
		    my @elements=split(/\s+/);
		    if(@elements != $sample_num){
			print STDERR "ERROR: migration matrix should be $sample_num by $sample_num!\n";
		    }
		    foreach my $x(@elements){
			if(&check_param($x)==1){
			    $params{$x}=1;
			}
		    }
		}
		$real_num++;
	    }
	    if($real_num != $sample_num){
		print STDERR "ERROR: migration matrix should be $sample_num by $sample_num!\n";
	    }
	}
    }
    else{
	my $check=<I>;
	if($check!~/historical/){
	    die "FATAL ERROR: $mig_num migration matrixes are expected, but there are more matrixes here!\n";
	}
    }
    my $historical_line=<I>;
    my $historical_num;
    if($historical_line=~/^(\d+)\s*historical/){
	$historical_num=$1;
    }
    else{
	die "FATAL ERROR: The sixth section should be historical events, but not found!\n";
    }
    $real_num=0;
    while(<I>){
	chomp;
        if(/^\/\//){
            last;
        }	
	my @elements=split(/\s+/);
	my @x=(0,3,4,5,6);
	foreach my $x(@x){
	    my $px=$elements[$x];
	    if($x==6 && ($px eq "keep" || $px eq "nomig")){
		next;
	    }
	    # test if the migration matrix exists
	    if($x==6){
		if($px=~/^\d+$/){
		    if($px == $mig_num && $mig_num == 0){
			next;
		    }
		    if($px >= $mig_num){
			print STDERR "ERROR: migration matrix $px does not exists!\nin line:\n$_\n";
		    }
		}
	    }
	    # test complete
	    if(&check_param($px)==1){
		$params{$px}=1;
	    }
	}
	$real_num++;
    }
    if($real_num != $historical_num){
	print STDERR "ERROR: $historical_num history events expected, but there were $real_num here!\n";
    }
    close I;
    return(%params);
}

sub check_param{
    my $x=shift;
    chomp $x;
    my $status=1;
    if($x=~/^\d+$/){
	$status=0;
    }
    elsif($x=~/^\d+\.\d+$/){
	$status=0;
    }
    elsif($x=~/^\d+e\d+$/i){
	$status=0;
    }
    elsif($x=~/^\d+\.\d+e\d+/i){
	$status=0;
    }
    elsif($x=~/^\d+e\-\d+$/i){
	$status=0;
    }
    elsif($x=~/^\d+\.\d+e\-\d+/i){
	$status=0;
    }
    # print "$x\t$status\n";
    return($status);
}

sub check_est{
    my $file=shift;
    my %simple;
    my $section_status="NULL"; # this is used to specify which section you are
    open(I,"< $file") or die "Cannot read $file!\n";
    my $line_num=0;
    while(<I>){
	$line_num++;
	chomp;
	next if(/^\/\//);
	next if(/^\s*$/);
	if(/^\[/){
	    if(/\[PARAMETERS\]/){
		$section_status="SIMPLE";
	    }
	    elsif(/RULES/){
		$section_status="RULES";
	    }
	    elsif(/COMPLEX/){
		$section_status="COMPLEX";
	    }
	    next;
	}
	my @elements = split(/\s+/);
	if($section_status eq "SIMPLE"){
	    my $param=$elements[1];
	    $simple{$param}++;
	}
	elsif($section_status eq "RULES"){

	}
	elsif($section_status eq "COMPLEX"){
	    my $left=$elements[1];
	    my $right=$elements[3];
	    $right=~s/[+\-\*\/]/ /g;
	    $right=~s/(%min%|%max%)/ /g;
	    $right=~s/abs\(([^\(\)]+)\)/$1 /g;
	    $right=~s/exp\(([^\(\)]+)\)/$1 /g;
	    $right=~s/log\(([^\(\)]+)\)/$1 /g;
	    $right=~s/log10\(([^\(\)]+)\)/$1 /g;
	    $right=~s/pow10\(([^\(\)]+)\)/$1 /g;
	    # print "$left\t$right\n";
	    $right=~s/^\s+//;
	    my @right=split(/\s+/,$right);
	    foreach my $param(@right){
		if($param!~/^[\d\.\e]+$/ && !exists $simple{$param}){
		    print STDERR "ERROR: [ $param ] does not defined!\tLine: $line_num\n";
		}
		else{
		    $simple{$param}=0; # This indicate that $param had already been used.
		}
	    }
	    $simple{$left}=1;
	}
    }
    close I;
    return(%simple);
}

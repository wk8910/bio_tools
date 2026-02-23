#! /usr/bin/env perl
use strict;
use warnings;

my $smc="/home/share/user/user101/software/smcpp/smcpp-build/bin/smc++";
my $generation_time=15;
my $input_dir="smc_analysis";
my $split_dir="smc_split";
my $out_dir="smc_split_analysis";
my $pdf_dir="smc_split_pdf";
`mkdir $out_dir` if(!-e $out_dir);
`mkdir $pdf_dir` if(!-e $pdf_dir);

my @pop=<$input_dir/*>;
@pop=sort @pop;

open O,"> $0.sh";
for(my $i=0;$i<@pop;$i++){
    for(my $j=$i+1;$j<@pop;$j++){
	my $pop1=$pop[$i];
	$pop1=~/([^\/]+)$/;
	my $id1=$1;

	my $pop2=$pop[$j];
	$pop2=~/([^\/]+)$/;
	my $id2=$1;

	my $split_name=$id1."_".$id2;

	`mkdir $out_dir/$split_name` if(!-e "$out_dir/$split_name");

	print O "$smc split -o $out_dir/$split_name $pop1/model.final.json $pop2/model.final.json $split_dir/$split_name/*.smc.gz; $smc plot -g $generation_time $pdf_dir/$split_name.pdf $out_dir/$split_name/model.final.json\n";
    }
}

close O;

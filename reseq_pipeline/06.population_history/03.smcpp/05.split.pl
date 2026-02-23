#! /usr/bin/env perl
use strict;
use warnings;

my $pop="pop.lst";
my $vcf="snp.vcf.gz";
my $dict="/home/share/user/user101/projects/yangshu/11.ref/ptr.dict";
my $smc="/home/share/user/user101/software/smcpp/smcpp-build/bin/smc++";
my $min_len=10000;
my $out_dir="smc_split";

`mkdir $out_dir` if(!-e $out_dir);

my %pop;
open I,"< $pop";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($ind,$pop)=@a;
    $pop{$pop}{$ind}=1;
}
close I;

my @pop = sort keys %pop;

open O,"> $0.sh";
open I,"< $dict";
while(<I>){
    chomp;
    next unless(/SN:(\S+)\s+LN:(\d+)/);
    my ($chr,$len)=($1,$2);
    next if($len<$min_len);

    for(my $i=0;$i<@pop;$i++){
	for(my $j=$i+1;$j<@pop;$j++){
	    my $pop1 = $pop[$i];
	    my $pop2 = $pop[$j];
	    my $name=$pop1."_".$pop2;
	    `mkdir $out_dir/$name` if(!-e "$out_dir/$name");
	    my @ind1=sort keys %{$pop{$pop1}};
	    my @ind2=sort keys %{$pop{$pop2}};
	    my $ind1=join ",",@ind1;
	    my $ind2=join ",",@ind2;
	    print O "$smc vcf2smc $vcf $out_dir/$name/$chr.smc.gz $chr $pop1:$ind1 $pop2:$ind2\n";
	}
    }
}
close I;
close O;

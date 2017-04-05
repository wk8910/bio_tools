#! /usr/bin/env perl
use strict;
use warnings;

my $pop="pop.lst";
my $vcf="snp.vcf.gz";
my $dict="/home/share/user/user101/projects/yangshu/11.ref/ptr.dict";
my $smc="/home/share/user/user101/software/smcpp/smcpp-build/bin/smc++";
my $min_len=10000;
my $out_dir="smc_input";

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

open O,"> $0.sh";
open I,"< $dict";
while(<I>){
    chomp;
    next unless(/SN:(\S+)\s+LN:(\d+)/);
    my ($chr,$len)=($1,$2);
    next if($len<$min_len);
    foreach my $pop(sort keys %pop){
	`mkdir $out_dir/$pop` if(!-e "$out_dir/$pop");
	my @ind=sort keys %{$pop{$pop}};
	my $ind=join ",",@ind;
	print O "$smc vcf2smc $vcf $out_dir/$pop/$chr.smc.gz $chr $pop:$ind\n";
    }
}
close I;
close O;

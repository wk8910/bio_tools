#! /usr/bin/env perl
use strict;
use warnings;

my ($vcf,$pop_list,$out_dir)=@ARGV;
die "Usage: $0 <vcf file> <pop list> <output directory>\npop list format:\ngroup_name\tindividual_name\n说    明: 从vcf文件中提取出专门用于fsc模拟的二维频谱\n注意事项: 1,不允许存在unknown位点; 2,非SNP位点也必须包括在该VCF中\n" if(@ARGV<3);
`mkdir $out_dir` if(!-e "$out_dir");

my %pop;
my %pop_name;
open(I,"< $pop_list") or die "Cannot open $pop_list";
while(<I>){
    chomp;
    my ($pop_name,$ind_name)=split(/\s+/);
    $pop{$ind_name}=$pop_name;
    $pop_name{$pop_name}++;
}
close I;

open(O,"> $out_dir/pop.info");
print O "#NO\tChromosome_Number\tPopulation_Name\n";
my $pop_seq=0;
my @pop_name = sort keys %pop_name;
foreach my $pop_name(@pop_name){
    my $chromosome_number=$pop_name{$pop_name}*2;
    print O "$pop_seq\t$chromosome_number\t$pop_name\n";
    $pop_seq++;
}
close O;

my %maf;
if($vcf=~/gz$/){
    open(I,"zcat $vcf |") or die "Cannot open $vcf!\n";
}
else{
    open(I,"< $vcf") or die "Cannot open $vcf!\n";
}
my @vcf_head;
while(<I>){
    next if(/^##/);
    if(/^#/){
	chomp;
	@vcf_head=split(/\s+/);
	last;
    }
}
my $control=0;
my $no_snp=0;
while(<I>){
    chomp;
    next if(/\.[|\/]\./);
    $control++;
    if($control % 1000000 == 0){
	print STDERR "$control sites loaded\n";
    }

    my @elements=split(/\s+/);
    if($elements[4] eq "." || $elements[3] eq $elements[4]){
	$no_snp++;
	next;
    }
    my $alternative_site_count=0;
    my $all_num = 0;
    for(my $i=9;$i<@elements;$i++){
	my $ind_name=$vcf_head[$i];
	next if(!exists $pop{$ind_name});
	$all_num=$all_num+2;
	die "No missing site was allowed in vcf file!\n$_\n$elements[$i]\n" unless($elements[$i]=~/^(\d)[\/|](\d)/);
	my ($left,$right)=($1,$2);
	$alternative_site_count=$alternative_site_count+$left+$right;
    }
    if($all_num==0){
	die "There is no individual in the pop list survive in the vcf file!\n";
    }
    my $minor=0;
    if($alternative_site_count>=($all_num/2)){
	$minor=1;
    }
    my %freq;
    for(my $i=9;$i<@elements;$i++){
	$elements[$i]=~/^(\d)[\/|](\d)/;
	my ($left,$right)=($1,$2);
	if($minor==1){
	    $left=1-$left;
	    $right=1-$right;
	}
	my $ind_name=$vcf_head[$i];
	next if(!exists $pop{$ind_name});
	my $pop_name=$pop{$ind_name};
	if(!$freq{$pop_name}){
	    $freq{$pop_name}=0;
	}
	$freq{$pop_name} = $freq{$pop_name}+$left+$right;
    }
    for(my $i=0;$i<@pop_name;$i++){
	my $pop_x=$pop_name[$i];
	for(my $j=$i+1;$j<@pop_name;$j++){
	    my $pop_y=$pop_name[$j];
	    my $combination=$pop_x."vs".$pop_y;
	    my $freq_x=$freq{$pop_x};
	    my $freq_y=$freq{$pop_y};
	    $maf{$combination}{$freq_x}{$freq_y}++;
	}
    }
    # last;
}
close I;

for(my $i=0;$i<@pop_name;$i++){
    my $pop_x=$pop_name[$i];
    for(my $j=$i+1;$j<@pop_name;$j++){
	my $pop_y=$pop_name[$j];
	my $combination=$pop_x."vs".$pop_y;
	my $freq_x=0;
	my $freq_y=0;
	$maf{$combination}{$freq_x}{$freq_y}+=$no_snp;
    }
}

for(my $i=0;$i<@pop_name;$i++){
    my $pop_x=$pop_name[$i];
    my $chr_num_x=$pop_name{$pop_x}*2;
    my @head_x=("");
    for(my $m=0;$m<=$chr_num_x;$m++){
	my $string="d$i"."_".$m;
	push @head_x,$string;
    }
    for(my $j=$i+1;$j<@pop_name;$j++){
	my $pop_y=$pop_name[$j];
	my $chr_num_y=$pop_name{$pop_y}*2;
	my $combination=$pop_x."vs".$pop_y;
	my $out_sfs="$out_dir/model_jointMAFpop$j"."_$i.obs";
	open(O,"> $out_sfs") or die "Cannot create $out_sfs\n";
	print O "1 observations\n";
	print O join "\t",@head_x,"\n";
	for(my $n=0;$n<=$chr_num_y;$n++){
	    my $string="d$j"."_".$n;
	    my @line=($string);
	    for(my $m=0;$m<=$chr_num_x;$m++){
		my $num=0;
		if(exists $maf{$combination}{$m}{$n}){
		    $num=$maf{$combination}{$m}{$n};
		}
		push @line,"$num";
	    }
	    print O join "\t",@line,"\n";
	}
	close O;
    }
}

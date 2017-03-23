#! /usr/bin/env perl
use strict;
use warnings;

my $vcf_dir="vcf";
my @vcf=<$vcf_dir/*.vcf.gz>;
my $out="non_repeat.vcf.gz";
my $non_repeat="keep.bed";
my $window_size=10000;

my %non_repeat;
my %check_list;
open(I,"< $non_repeat");
my $number=0;
while(<I>){
    chomp;
    $number++;
    my ($chr,$start,$end)=split(/\s+/);
    my $left=int($start/$window_size);
    my $right=int($end/$window_size);
    if($left<$right){
        for(my $i=$left+1;$i<=$right;$i++){
            my $temp_end=$i * $window_size - 1;
            # print "$chr\t$start\t$temp_end\n";
            &save($chr,$start,$temp_end,$number);
            $start = $i * $window_size;
        }
        my $temp_start = $right * $window_size;
        # print "$chr\t$temp_start\t$end\n";
        &save($chr,$temp_start,$end,$number);
    }
    else{
        # print "$chr\t$start\t$end\n";
        &save($chr,$start,$end,$number);
    }
}
close I;

print STDERR "non repeat sites loaded!\n";

sub save{
    my ($chr,$start,$end,$number)=@_;
    my $left=int($start/$window_size);
    my $bar_code="$chr"."-".$left;
    $non_repeat{$bar_code}{$number}{chr}=$chr;
    $non_repeat{$bar_code}{$number}{start}=$start;
    $non_repeat{$bar_code}{$number}{end}=$end;
    # print "$bar_code\t$number\t$chr\t$start\t$end\n";
}

my %hash;
foreach my $vcf(@vcf){
    $vcf=~/(\d+).vcf.gz/;
    my $order=$1;
    $hash{$order}=$vcf;
}

@vcf=();
foreach my $order(sort {$a<=>$b} keys %hash){
    push @vcf,$hash{$order};
    # print "$order\t$hash{$order}\n";
}

print STDERR "Reading vcf now!\n";

my $control=0;
my $present_bar_code="NA";
open(O,"| gzip - > $out");
foreach my $vcf(@vcf){
    print STDERR "Reading $vcf\n";
    open(I,"zcat $vcf |");
    while(<I>){
        if(/^#/){
            next if($control>0);
            print O "$_";
        }
        else{
            chomp;
            my @a=split(/\s+/);
            next unless($a[7]=~/DP=(\d+)/);
            my $dp=$1;
            # next if($dp > 2900 || $dp < 116);
            my ($chr,$pos)=($a[0],$a[1]);
            my $left=int($pos/$window_size);
            my $bar_code="$chr"."-".$left;
            if($bar_code ne $present_bar_code){
	&decompress($bar_code);
	$present_bar_code=$bar_code;
            }
            next unless(exists $check_list{$pos});
            print O "$_\n";
        }
    }
    close I;
    $control++;
}
close O;

sub decompress{
    my $bar_code=shift;
    %check_list=();
    foreach my $number(keys %{$non_repeat{$bar_code}}){
        my $start=$non_repeat{$bar_code}{$number}{start};
        my $end=$non_repeat{$bar_code}{$number}{end};
        for(my $i=$start;$i<=$end;$i++){
            $check_list{$i}=1;
        }
    }
}

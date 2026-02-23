#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};

`mkdir bam` if(!-e "bam");

my @dir=("/home/share/user/user101/projects/yangshu/10.pretty_reads/Populus_rotundifolia_var_duclouxiana","/home/share/user/user101/projects/yangshu/10.pretty_reads/Populus_davidiana");

open(O,"> $0.sh");
foreach my $dir(@dir){
    my @ind=<$dir/*>;
    foreach my $ind(@ind){
	# print "$ind\n";
	my @reads1=<$ind/*1.clean.fq.gz>;
	$ind=~/([^\/]+)$/;
	my $name=$1;
	my $num=0;
	foreach my $reads1(@reads1){
	    $num++;
	    my $reads2=$reads1;
	    $reads2=~s/1.clean.fq.gz/2.clean.fq.gz/;
	    my $new_name=$name.".".$num;
	    print O "/home/share/user/user101/software/bwa/bwa-0.7.8/bwa mem -t 12 -R '\@RG\tID:$name\tSM:$name\tLB:$new_name' /home/share/user/user101/projects/yangshu/11.ref/ptr.fa $reads1 $reads2 | /home/share/user/user101/bin/samtools sort -O bam -T $now/$new_name -l 3 -o $now/bam/$new_name.bam -\n";
	}
    }
    # last;
}
close O;

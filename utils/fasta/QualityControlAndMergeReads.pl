#! /usr/bin/perl
use strict;
use warnings;

# This script is used to filter reads quality. If multiple pair of reads are provided, there will be merged into one pair of reads.
# The quality base should be same within all pair of reads.
# by Yongzhi Yang.

my $out_prefix=shift @ARGV;
my @file=@ARGV;
if(scalar(@ARGV) == 0 || scalar(@ARGV)%2 > 0){
    die "Usage:\n$0 \$out_prefix a.fq1 a.fq2 b.fq1 b.fq2 ...\n";
}
my $baseQ=&getBaseQ();
my $out1="$out_prefix.1.filter.fq.gz";
my $out2="$out_prefix.2.filter.fq.gz";
print "baseQ is $baseQ\noutput files: $out1\t$out2\n";
open(O1,"| gzip - > $out1")||die("$!\n");
open(O2,"| gzip - > $out2")||die("$!\n");

for (my $j=0;$j<@file;$j=$j+2){
    my $file1=$file[$j];
    my $file2=$file[$j+1];
    print "filter $file1 $file2\n";
    if ($file1=~/gz$/){
        open(I1,"zcat $file1 |")||die("$!\n");
        open(I2,"zcat $file2 |")||die("$!\n");
    }else{
        open(I1,"< $file1")||die("$!\n");
        open(I2,"< $file2")||die("$!\n");
    }
    while(<I1>){
        my $l1=$_;chomp $l1;
        my $l2=<I1>;chomp $l2;
        my $l3=<I1>;chomp $l3;
        my $l4=<I1>;chomp $l4;
        my $l5=<I2>;chomp $l5;
        my $l6=<I2>;chomp $l6;
        my $l7=<I2>;chomp $l7;
        my $l8=<I2>;chomp $l8;
        
        my $test2=&filter($l2,$l4);
        #print "$test2\n";
        next if($test2==0);
        my $test6=&filter($l6,$l8);
        #print "$test6\n";
        next if($test6==0);
        
        if ($baseQ == 64){
            $l4=&quality33($l4);
            $l8=&quality33($l8);
        }
        print O1 "$l1\n","$l2\n","+\n","$l4\n";
        print O2 "$l5\n","$l6\n","+\n","$l8\n";
    }
    close I1;
    close I2;
    print "done\n";
}
close O1;
close O2;

sub getBaseQ{
    my $infile=$file[0];
    if ($infile=~/(gz|gzip)$/){
        open (F,"zcat $infile| ") or die "Cannot open $infile\n";
    }else{
        open (F,"$infile") or die "Cannot open $infile\n";
    }
    my $i=0;
    my $min=100;
    while (<F>) {
        chomp;
        $i++;
        if ($i%4 == 0){
            my $len=length($_);
            my @Q=split(//,$_);
            for my $q (@Q){
	$q=ord("$q");
	$min=$q if ($q<=$min);
            }
        }
        last if $i==100000;
    }
    close F;
    $min = ($min>=64 ? 64 : 33);
    return ($min);
}

sub filter{
    my ($seq,$qual)=@_;
    chomp $seq;
    chomp $qual;
    my $len=length($seq);
    return(0) if($len==0);
    my $n=$seq;
    $n=~s/N//g;
    my $lenN=length($n);
    return(0) if($lenN/$len<0.95);
    my @quality=split(//,$qual);
    my $invalid=0;
    foreach my $a(@quality){
        my $b=ord($a)-$baseQ;
        $invalid++ if($b<=7);
    }
    return(0) if($invalid/$len>=0.65);
    return(1);
}

sub quality33 {
    my ($line)=@_;
    chomp $line;
    my @line=split(//,$line);
    my @newline;
    for my $q (@line){
        my $Q=ord($q)-64;
        my $newq=chr(($Q<=93 ? $Q : 93) + 33);
        push @newline,$newq;
    }
    my $newline=join("",@newline);
    return $newline;
}

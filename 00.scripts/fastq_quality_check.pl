#! /usr/bin/env perl
use strict;
use warnings;

my $file=shift;

die "Usage: $0 <fastq file>\n" if(!defined $file || !-e $file);

if($file=~/.gz$/){
    open(I,"zcat $file |");
}
else{
    open(I,"< $file");
}

my %hash;
my $control=0;
while(<I>){
    <I>;
    <I>;
    my $quality=<I>;
    # print "$quality\n";
    chomp $quality;
    my @quality=split(//,$quality);
    for(my $i=0;$i<@quality;$i++){
	my $x=ord($quality[$i]);
	$hash{$x}++;
    }
    # last;
    last if($control++>10000);
}

close I;

my @qual=sort {$a<=>$b} keys %hash;
my $min=$qual[0];
my $max=$qual[-1];

print "Qual score from $min to $max\n";
if($min<64 && $max<93){
    print "Quality is 33 based\n";
}
elsif($min>=64){
    print "Quality is 64 based\n";
}
else{
    print "Out of range. perhaps mixed quality!\n";
}

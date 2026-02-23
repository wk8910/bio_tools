#! /usr/bin/env perl
use strict;
use warnings;

my ($vcf,$outdir)=@ARGV;
die "Usage: $0 <vcf file> <outdir>" if(!-e $vcf || ! $outdir);
my $wind_size=500000;

`mkdir $outdir` if(!-e $outdir);

if($vcf=~/.gz$/){
    open I,"zcat $vcf |" or die "Cannot open $vcf!\n";
}
else{
    open I,"< $vcf" or die "Cannot open $vcf!\n";
}

my @head;
my $code="NA";
my $effective_length=0;
my %seq;
my $control=0;
while(<I>){
    next if(/^##/);
    chomp;
    my @a=split(/\s+/);
    if(/^#/){
	@head=@a;
	next;
    }
    my ($chr,$pos,$ref,$alt)=($a[0],$a[1],$a[3],$a[4]);
    next if(length($alt)>1);
    my $index=int($pos/$wind_size)*$wind_size;
    $index = $chr.".".$index;
    # print STDERR "$index\n";
    if($index ne $code){
	print STDERR "$index\n";
	# last if($control++>100);

	&output($code);
	$effective_length=0;
	for(my $i=9;$i<@head;$i++){
	    my $id=$head[$i];
	    $seq{$id}="";
	}
    }
    $code=$index;
    my $light=1;
    my ($total_num,$missing_num)=(0,0);
    for(my $i=9;$i<@a;$i++){
	if($a[$i]=~/\.\/\./){
	    $missing_num++;
	}
	$total_num++;
    }
    next if($missing_num/$total_num > 0.5);
    for(my $i=9;$i<@a;$i++){
        my $id=$head[$i];
        my $base="N";

        if($a[$i]=~/1\/1/){
            $base=$alt;
        }
        elsif($a[$i]=~/0\/0/){
            $base=$ref;
        }
        elsif($a[$i]=~/0\/1/){
            my $rand=rand(1);
            if($rand<0.5){
                $base=$ref;
            }
            else{
                $base=$alt;
            }
        }
	$light=0 if($base eq "N");
        $seq{$id}.=$base;
    }
    $effective_length++ if($light==1);
}
&output($code);
close I;

sub output{
    my $code=shift;
    return() if($code eq "NA");
    # if($effective_length/$wind_size < 0.2){
    if($effective_length < 2000){
	print STDERR "$effective_length\t$wind_size\n";
	return();
    }
    `mkdir "$outdir/$code"` if(!-e "$outdir/$code");
    open O,"> $outdir/$code/align.fa" or die "Cannot create $outdir\/$code\/align.fa!\n";
    foreach my $id(sort keys %seq){
	print O ">$id\n$seq{$id}\n";
    }
    close O;
}

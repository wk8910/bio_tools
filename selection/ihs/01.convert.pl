#! /usr/bin/env perl
use strict;
use warnings;

my $vcf = "Y1.phase.vcf.gz.vcf.gz";

my $outdir="chr";
`mkdir $outdir` if(!-e $outdir);

my %haplotype;
open I,"zcat $vcf |" or die "Cannot open $vcf!\n";
my $chr_pre = "NA";
while(<I>){
    chomp;
    next if(/^#/);
    next unless(/1\|1/ or /0\|1/ or /1\|0/);
    my @a=split(/\s+/);
    my ($chr,$pos,$ref,$alt)=($a[0],$a[1],$a[3],$a[4]);
    # next if($chr!~/Chr\d+/);
    my $id = $chr."_".$pos;
    if($chr ne $chr_pre){
	close M;
	open M,"> $outdir/$chr.map";

	if($chr_pre ne "NA"){
	    &hap_out($chr_pre);
	}
    }
    my $g_pos = $pos/1e6;
    # print M "$id $pos $g_pos $ref $alt\n";
    print M "$chr $id $g_pos $pos\n";
    my $num = 1;
    for(my $i=9;$i<@a;$i++){
	$a[$i]=~/([01])\|([01])/;
	my ($left,$right)=($1,$2);
	$haplotype{$num}.="$left ";
	$num++;
	$haplotype{$num}.="$right ";
	$num++;
    }
    $chr_pre = $chr;
}

&hap_out($chr_pre);

close I;
close M;

sub hap_out{
    my $chr=shift;
    open O,"> $outdir/$chr.hap";
    foreach my $hap(sort {$a<=>$b} keys %haplotype){
	my $line = $haplotype{$hap};
	$line=~s/\s*$//;
	print O "$line\n";
    }
    %haplotype = ();
    close O;
}

#! /usr/bin/env perl
use strict;
use warnings;

my $bim="plink.bim";
my $bed="../plink.bed";

if(!-e "$bim.bak"){
    `cp $bim $bim.bak`;

    open(I,"< $bim.bak");
    open(O,"> $bim");
    my $max=0;
    while(<I>){
	chomp;
	my @a=split(/\s+/);
	if($a[0]=~/^\d+$/){
	    if($max<$a[0]){
		$max=$a[0];
	    }
	}
    }
    close I;
    my %scaffold;
    open(I,"< $bim.bak");
    while(<I>){
	chomp;
	my @a=split(/\s+/);
	if($a[0]!~/^\d+$/){
	    if(!exists $scaffold{$a[0]}){
		$scaffold{$a[0]}=1;
		$max++;
	    }
	    $a[0]=$max;
	}
	print O join "\t",@a,"\n";
    }
    close O;
    close I;
}

open(O,"> $0.sh");
for(my $i=1;$i<=20;$i++){
    print O "/home/share/user/user101/software/admixture/admixture_linux-1.23/admixture --cv -j12 $bed $i | tee $bed.$i.log\n";
}
close O;

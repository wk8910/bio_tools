#! /usr/bin/env perl
use strict;
use warnings;

my $file=shift;
my $out="$file.fasta";
open I,"zcat $file |";
my %sequences;
my %locus;
while (<I>) {
    chomp;
    next unless(/\/gene=(\S+)/);
    my $gene_id=$1;
    $gene_id=~s/"//g;
    my $locus=<I>;
    if($locus=~/locus_tag=(\S+)/){
	my $locus_id=$1;
	$locus_id=~s/"//g;
	print STDERR "$gene_id\t$locus_id\n";
	$locus{$gene_id}=$locus_id;
	while(<I>){
	    chomp;
	    last if(/\s+gene\s+/);
	    if(/protein_id=\"([^"]+)\"/){
		my $protein_id=$1;
		my $seq="";
		while(<I>){
		    chomp;
		    my $light=1;
		    if(/\/translation="(.*)/){
			$seq.=$1;
			while(<I>){
			    chomp;
			    $seq.=$_;
			    $seq=~s/\s//g;
			    if(/"$/){
				$light=0;
				last;
			    }
			}
		    }
		    last if($light==0);
		}
		$seq=~s/"//g;
		$sequences{$gene_id}{$protein_id}=$seq;
	    }
	}
    }
}
close I;

open O,"> $out";
foreach my $gene_id(sort keys %sequences){
    next unless(exists $locus{$gene_id});
    my $locus_id=$locus{$gene_id};
    next if(keys %{$sequences{$gene_id}} == 0);
    my $seq="";
    my $selected_protein_id="";
    foreach my $protein_id(keys %{$sequences{$gene_id}}){
	if(length($sequences{$gene_id}{$protein_id}) > length($seq)){
	    $seq=$sequences{$gene_id}{$protein_id};
	    $selected_protein_id=$protein_id;
	}
    }
    print O ">$locus_id $gene_id $selected_protein_id\n$seq\n";
}
close O;

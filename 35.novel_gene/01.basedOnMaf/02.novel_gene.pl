#! /usr/bin/env perl
use strict;
use warnings;

my $point="point2point.lst.gz";
my $gff_dir="gff";
my $outdir="novel_genes";
`mkdir $outdir` if(!-e $outdir);

my %cds_sites;
my %gene;
my %len;
my @gff=<$gff_dir/*.gff>;
foreach my $gff(@gff){
    $gff=~/([^\/]+).gff$/;
    my $species_id=$1;
    open I,"< $gff";
    while(<I>){
        chomp;
        my @a=split(/\s+/);
        next unless($a[2] eq "CDS");
        my ($chr,$start,$end,$strand)=($a[0],$a[3],$a[4],$a[6]);
        $a[8]=~/Parent=([^;]+)/;
        my $id=$1;
        for(my $i=$start;$i<=$end;$i++){
            $cds_sites{$species_id}{$chr}{$i}=$id;
            $gene{$species_id}{$id}{pos}{$i}=0;
        }
        $gene{$species_id}{$id}{strand}=$strand;
        $len{$species_id}{$id}+=$end-$start+1;
    }
    close I;
    print STDERR "gff $species_id loaded...\n";
}

my %signal;
open I,"zcat $point |";
my $control=0;
while (<I>) {
    chomp;
    next if(/^\s*$/);
    my @a=split(/\s+/);
    my $light=0;
    my %strand;
    for(my $i=0;$i<@a;$i+=4){
        my ($species_id,$chr,$strand,$pos)=($a[$i],$a[$i+1],$a[$i+2],$a[$i+3]);
        if(!exists $gene{$species_id}){
            next;
        }
        $light++;
        if(exists $cds_sites{$species_id}{$chr}{$pos}){
            my $gene_id=$cds_sites{$species_id}{$chr}{$pos};
            my $gene_strand=$gene{$species_id}{$gene_id};
            if($gene_strand ne $strand){
	$strand{minus}{$species_id}=$gene_id;
            }
            else {
	$strand{plus}{$species_id}=$gene_id;
            }
        }
    }
    next unless($light>0);
    foreach my $strand(keys %strand){
        my @species_id = sort keys %{$strand{$strand}};
        my $signal=join "|",@species_id;
        my @cluster_genes;
        foreach my $species_id(sort keys %{$strand{$strand}}){
            my $gene_id=$strand{$strand}{$species_id};
            push @cluster_genes,$gene_id;
        }
        my $cluster_genes=join "|",@cluster_genes;
        foreach my $species_id(sort keys %{$strand{$strand}}){
            my $gene_id=$strand{$strand}{$species_id};
            $signal{$species_id}{$gene_id}{$signal}{count}++;
            $signal{$species_id}{$gene_id}{$signal}{cluster}{$cluster_genes}++;
        }
    }
    $control++;
    if($control%10000==0){
        print STDERR "$control sites loaded...\n";
    }
}
close I;

foreach my $species_id(sort keys %signal){
    open O,"> $outdir/$species_id.info";
    open N,"> $outdir/$species_id.novel_gene";
    foreach my $gene_id(sort keys %{$signal{$species_id}}){
        my $len=$len{$species_id}{$gene_id};
        my @signal=sort keys %{$signal{$species_id}{$gene_id}};
        if(@signal == 1 && $signal[0] eq $species_id){
            my $eff_len=$signal{$species_id}{$gene_id}{$signal[0]}{count};
            print N "$gene_id\t$len\t$eff_len\n";
        }
        my @line=($gene_id,$len);
        foreach my $signal(@signal){
            my $eff_len=$signal{$species_id}{$gene_id}{$signal}{count};
            my $info="$signal($eff_len):";
            foreach my $cluster_genes(sort keys %{$signal{$species_id}{$gene_id}{$signal}{cluster}}){
	my $sub_len=$signal{$species_id}{$gene_id}{$signal}{cluster}{$cluster_genes};
	$info.="$cluster_genes($sub_len);";
            }
            push @line,$info;
        }
        print O join "\t",@line,"\n";
    }
    close O;
    close N;
}

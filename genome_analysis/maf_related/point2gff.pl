#! /usr/bin/env perl
use strict;
use warnings;

my $gff="clean.noStopCodon.gff";
my $point="point2point.lst.gz";
my $ref_species="cattle";
my $out_prefix=$0;

my %gff;
my %info;
my %site;
open I,"< $gff";
while(<I>){
    my @a=split(/\s+/);
    my ($chr,$source,$type,$start,$end,$score,$strand,$phase,$info)=@a;
    $info=~/Parent=([^,;]+)/;
    my $gene_id=$1;
    $info{$gene_id}{strand}=$strand;
    $info{$gene_id}{chr}=$chr;
    for(my $i=$start;$i<=$end;$i++){
	$gff{$gene_id}{$i}=1;
	$site{$chr}{$i}=$gene_id;
    }
}
close I;

my %codon;
foreach my $gene_id(keys %gff){
    my $strand=$info{$gene_id}{strand};
    if($strand eq "+"){
	my $codon=1;
	my $light=0;
	foreach my $i(sort {$a<=>$b} keys %{$gff{$gene_id}}){
	    if($light==3){
		$light=0;
		$codon++;
	    }
	    $codon{$gene_id}{$i}=$codon.".".$light;
	    $light++;
	}
    }
    elsif($strand eq "-"){
	my $codon=1;
	my $light=0;
	foreach my $i(sort {$b<=>$a} keys %{$gff{$gene_id}}){
	    if($light==3){
		$light=0;
		$codon++;
	    }
	    $codon{$gene_id}{$i}=$codon.".".$light;
	    $light++;
	}
    }
}

my %data;
open I,"zcat $point |" or die "Cannot open $point!\n";
while(<I>){
    chomp;
    next if(/^\s*$/);
    next if(/^#/);
    my @a=split(/\s+/);
    my %pos;
    for(my $i=0;$i<@a;$i+=4){
	my ($species,$chr,$strand,$pos)=($a[$i],$a[$i+1],$a[$i+2],$a[$i+3]);
	$pos{$species}{chr}=$chr;
	$pos{$species}{pos}=$pos;
	$pos{$species}{strand}=$strand;
    }
    my ($ref_chr,$ref_pos,$ref_strand);
    if(!exists $pos{$ref_species}){
	die "$ref_species could not be find here!\n";
    }
    else{
	$ref_chr=$pos{$ref_species}{chr};
	$ref_pos=$pos{$ref_species}{pos};
	$ref_strand=$pos{$ref_species}{strand};
    }
    next if(!exists $site{$ref_chr}{$ref_pos});
    my $gene_id=$site{$ref_chr}{$ref_pos};
    my $codon=$codon{$gene_id}{$ref_pos};
    $codon=~/(\d+)\.(\d+)/;
    my ($seq,$phase)=($1,$2);
    my $gene_strand=$info{$gene_id}{strand};
    foreach my $species(keys %pos){
	next if($species eq $ref_species);
	my $chr=$pos{$species}{chr};
	my $pos=$pos{$species}{pos};
	my $strand=$pos{$species}{strand};
	my $real_strand=&get_strand($strand,$gene_strand,$ref_strand);
	$data{$species}{$gene_id}{$seq}{$phase}=join "\t",($chr,$pos,$real_strand);
    }
}
close I;

foreach my $species(sort keys %data){
    print "$species\n";
    my $out="$out_prefix.$species.gff";
    open O,"> $out";
    foreach my $gene_id(sort keys %{$data{$species}}){
	my ($chr_pre,$strand_pre,$pos_start,$pos_end,$phase_start,$phase_end)=("NA","NA","NA","NA","NA","NA");
	foreach my $seq(sort {$a<=>$b} keys %{$data{$species}{$gene_id}}){
	    my $num=keys %{$data{$species}{$gene_id}{$seq}};
	    next unless($num==3);
	    foreach my $phase(sort {$a<=>$b} keys %{$data{$species}{$gene_id}{$seq}}){
		my $content = $data{$species}{$gene_id}{$seq}{$phase};
		my ($chr,$pos,$strand)=split(/\s+/,$content);
		if($chr_pre eq "NA"){
		    $chr_pre=$chr;
		    $strand_pre=$strand;
		    $pos_start=$pos;
		    $pos_end=$pos;
		    $phase_start=$phase;
		    $phase_end=$phase;
		}
		else{
		    if($chr_pre eq $chr && abs($pos_end-$pos)==1 && $strand_pre eq $strand){
			$pos_end=$pos;
			$phase_end=$phase;
		    }
		    else{
			&flowing($gene_id,$chr_pre,$strand_pre,$pos_start,$pos_end,$phase_start,$phase_end);
			$chr_pre=$chr;
			$strand_pre=$strand;
			$pos_start=$pos;
			$pos_end=$pos;
			$phase_start=$phase;
			$phase_end=$phase;
		    }
		}
		# print "$gene_id\t$phase\t$content\n";
	    }
	}
	&flowing($gene_id,$chr_pre,$strand_pre,$pos_start,$pos_end,$phase_start,$phase_end);
    }
    close O;
}

sub flowing{
    my ($gene_id,$chr_pre,$strand_pre,$pos_start,$pos_end,$phase_start,$phase_end)=@_;
    my $chr=$chr_pre;
    my $source="synteny.$ref_species";
    my $type="CDS";
    my ($start,$end)=($pos_start,$pos_end);
    if($start>$end){
	($start,$end)=($pos_end,$pos_start);
    }
    my $score=".";
    my $strand=$strand_pre;
    my $phase=$phase_start;
    my $info="Parent=$gene_id;";
    my @line=($chr,$source,$type,$start,$end,$score,$strand,$phase,$info);
    print O join "\t",@line,"\n";
}

sub get_strand{
    my @x=@_;
    my $i=1;
    foreach my $x(@x){
	if($x eq "-"){
	    $i*=-1;
	}
    }
    my $result="+";
    if($i == -1){
	$result="-";
    }
    return($result);
}

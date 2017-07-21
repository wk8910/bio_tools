#! /usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

sub translate_nucl{
    my $seq=shift;
    my $seq_obj=Bio::Seq->new(-seq=>$seq,-alphabet=>'dna');
    my $pro=$seq_obj->translate;
    $pro=$pro->seq;
    return($pro);
}

my ($gff,$genome_fa,$cds)=@ARGV;
die "Usage: $0 <gff file> <genome file> <output>\n" if(@ARGV<3);
#my $gff="RefSeq_Btau_4.6.1_protein_coding.gff3";
#my $genome_fa="btau461.fa";
#my $cds="btau461.fa.cds";

my %gff;
open(I,"< $gff");
my $no=0;
while(<I>){
    chomp;
    next if(/^#/);
    next if(/^\s*$/);
    my @a=split(/\s+/);
    next unless($a[2] eq "CDS");
    $no++;
    my ($chr,$start,$end,$strand,$phase,$name)=($a[0],$a[3],$a[4],$a[6],$a[7],$a[8]);
    $chr=~s/chr//g;
    $name=~/Parent=([^;]+)/;
    $name=$1;
    $gff{$chr}{$name}{$no}{start}=$start;
    $gff{$chr}{$name}{$no}{end}=$end;
    $gff{$chr}{$name}{$no}{strand}=$strand;
    $gff{$chr}{$name}{$no}{phase}=$phase;
}
close I;

my $fa=Bio::SeqIO->new(-file=>$genome_fa,-format=>'fasta');

open(O,"> $cds");
open(E,"> $cds.pep");
while(my $seq=$fa->next_seq){
    my $chr=$seq->id;
    my $seq=$seq->seq;
    #print ">$id\n$seq\n";
    next unless(exists $gff{$chr});
    foreach my $name(keys %{$gff{$chr}}){
        my $strand="NA";
        my $line="";
        foreach my $no(sort { $gff{$chr}{$name}{$a}{start} <=> $gff{$chr}{$name}{$b}{start} } keys %{$gff{$chr}{$name}}){
            if($strand eq "NA"){
		$strand=$gff{$chr}{$name}{$no}{strand};
            }
            my $start=$gff{$chr}{$name}{$no}{start};
            my $end=$gff{$chr}{$name}{$no}{end};
            my $len=$end-$start+1;
            my $subline=substr($seq,$start-1,$len);
            $line.=$subline;
        }
        if($strand eq "+"){
            my $pep=translate_nucl($line);
            print O ">$name\n$line\n";
            print E ">$name\n$pep\n";
        }
        elsif($strand eq "-"){
            $line=reverse($line);
            $line=~tr/ATCGatcg/TAGCtagc/;
            my $pep=translate_nucl($line);
            print O ">$name\n$line\n";
            print E ">$name\n$pep\n";
        }
        print STDERR "$chr\t$name\n";
    }
}
close O;
close E;

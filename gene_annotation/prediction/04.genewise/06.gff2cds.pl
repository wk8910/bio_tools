#! /usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

my $gff="result/gene.gff";
my $genome_fa="../00.genome/sterlet.fa";
my $out_prefix="result/sterlet";

# die "Usage: $0 <gff file> <genome file> <output>\n" if(@ARGV<3);

my %gff;
my %len;
open(I,"< $gff");
my $no=0;
while(<I>){
    chomp;
    next if(/^#/);
    next if(/^\s*$/);
    my @a=split(/\s+/);
    next unless($a[2] eq "CDS");
    $no++;
    my ($chr,$source,$start,$end,$strand,$phase,$name)=($a[0],$a[1],$a[3],$a[4],$a[6],$a[7],$a[8]);
    # $chr=~s/chr//g;
    $name=~/Parent=([^;]+)/;
    $name=$1;
    if(!exists $len{$name}){
        $len{$name}{chr}=$chr;
        $len{$name}{source}=$source;
        $len{$name}{start}=$start;
        $len{$name}{end}=$end;
        $len{$name}{strand}=$strand;
    }
    else {
        if($start < $len{$name}{start}){
            $len{$name}{start}=$start;
        }
        if($end > $len{$name}{end}){
            $len{$name}{end} = $end;
        }
    }
    $len{$name}{cds}.=$_."\n";
    $gff{$chr}{$name}{$no}{start}=$start;
    $gff{$chr}{$name}{$no}{end}=$end;
    $gff{$chr}{$name}{$no}{strand}=$strand;
    $gff{$chr}{$name}{$no}{phase}=$phase;
}
close I;

my $fa=Bio::SeqIO->new(-file=>$genome_fa,-format=>'fasta');

my %whitelist;
my $extend_light=0;
open O,"> $out_prefix.cds";
open E,"> $out_prefix.pep";
open L,"> $out_prefix.log";
while(my $seq=$fa->next_seq){
    my $chr=$seq->id;
    my $seq=$seq->seq;
    my $len=length($seq);
    #print ">$id\n$seq\n";
    next unless(exists $gff{$chr});
    foreach my $name(keys %{$gff{$chr}}){
        my $strand="NA";
        my $line="";
        my $light=0;
        my ($min,$max)=("NA","NA");
        my $pep;
        foreach my $no(sort { $gff{$chr}{$name}{$a}{start} <=> $gff{$chr}{$name}{$b}{start} } keys %{$gff{$chr}{$name}}){
            if($strand eq "NA"){
	$strand=$gff{$chr}{$name}{$no}{strand};
            }
            my $start=$gff{$chr}{$name}{$no}{start};
            my $end=$gff{$chr}{$name}{$no}{end};

            if($min eq "NA"){
	$min=$start;
	$max=$end;
            }
            else {
	if($min>$start){
	    $min=$start;
	}
	if($max<$end){
	    $max=$end;
	}
            }

            my $len=$end-$start+1;
            my $subline=substr($seq,$start-1,$len);
            $line.=$subline;
        }
        if($strand eq "+"){
            $pep=&translate_nucl($line);
            $pep=~/^(.*).$/;
            my $stop_test=$1;
            if($stop_test=~/\*/){
	print L "$name\n";
            }
            $light=1;
        }
        elsif($strand eq "-"){
            $line=reverse($line);
            $line=~tr/ATCGatcg/TAGCtagc/;
            $pep=&translate_nucl($line);
            $pep=~/^(.*).$/;
            my $stop_test=$1;
            if($stop_test=~/\*/){
	print L "$name\n";
            }
            $light=1;
        }
        if($light==1){
            $whitelist{$chr}{$min}{$name}=1;
            # print STDERR "$chr\t$name\n";
            if($pep!~/\*$/){
	my ($extend,$extend_prot)=("NA","NA");
	if($strand eq "+" && $max<=$len-3){
	    $extend=substr($seq,$max,3);
	    $extend_prot=&translate_nucl($extend);
	}
	elsif($strand eq "-" && $min>3) {
	    $extend=substr($seq,$min-4,3);
	    $extend=reverse($extend);
	    $extend=~tr/ATCGatcg/TAGCtagc/;
	    $extend_prot=&translate_nucl($extend);
	}
	# print "$name\t$strand\t$extend\t$extend_prot\n";
	if($extend_prot eq "*"){
	    $extend_light=1;
	    $line.=$extend;
	    $pep.=$extend_prot;
	}
            }
            print O ">$name\n$line\n";
            print E ">$name\n$pep\n";
        }
    }
}
close O;
close E;
close L;

open O,"> $out_prefix.gff";
foreach my $chr(sort keys %whitelist){
    foreach my $min(sort {$a<=>$b} keys %{$whitelist{$chr}}){
        foreach my $name(sort keys %{$whitelist{$chr}{$min}}){
            my $source=$len{$name}{source};
            my $start=$len{$name}{start};
            my $end=$len{$name}{end};
            my $strand=$len{$name}{strand};

            my ($new_start,$new_end)=($start,$end);
            if($extend_light == 1){
	if($strand eq "+"){
	    $new_end=$new_end+3;
	}
	elsif ($strand eq "-") {
	    $new_start=$new_start-3;
	}
            }

            my @gene_line=($chr,$source,"gene",$new_start,$new_end,".",$strand,".","ID=$name;Parent=$name;");
            my $gene_line=join "\t",@gene_line;
            print O "$gene_line\n";
            my @mrna_line=($chr,$source,"mRNA",$new_start,$new_end,".",$strand,".","ID=$name;Parent=$name;");
            my $mrna_line=join "\t",@mrna_line;
            print O "$mrna_line\n";
            # print O "$len{$name}{cds}";
            my @cds=split(/\n/,$len{$name}{cds});
            foreach my $cds(@cds){
	my @a=split(/\s+/,$cds);
	if($a[3] == $start){
	    $a[3]=$new_start;
	}
	if($a[4] == $end){
	    $a[4]=$new_end;
	}
	my $line=join "\t",@a;
	print O "$line\n";
            }
        }
    }
}
close O;

sub translate_nucl{
    my $seq=shift;
    my $seq_obj=Bio::Seq->new(-seq=>$seq,-alphabet=>'dna');
    my $pro=$seq_obj->translate;
    $pro=$pro->seq;
    return($pro);
}

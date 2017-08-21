#! /usr/bin/env perl
use strict;
use warnings;

my $gff="gac.clean.gff";
my $lst="gac.maf.lst.gz";
my $dir="genes";
`mkdir $dir` if(!-e $dir);

my %gene;
my %pos;
open I,"< $gff";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    next unless($a[2] eq "CDS");
    my ($chr,$start,$end,$strand)=($a[0],$a[3],$a[4],$a[6]);
    $a[8]=~/Parent=(\w+)/;
    my $id=$1;
    for(my $i=$start;$i<=$end;$i++){
        $pos{$chr}{$i}=$id;
        $gene{$id}{pos}{$i}=0;
    }
    $gene{$id}{strand}=$strand;
}
close I;
print STDERR "$gff loaded...\n";

my %seq;
open I,"zcat $lst |";
my $head=<I>;
my @head=split(/\s+/,$head);
my $control=0;
while(<I>){
    my @a=split(/\s+/);
    my ($chr,$pos)=($a[0],$a[1]);
    next unless(exists $pos{$chr}{$pos});
    print STDERR "[ $control ] sites loaded...\r" if($control % 1000 == 0);
    my $id=$pos{$chr}{$pos};
    for(my $i=2;$i<@a;$i++){
        my $species=$head[$i];
        $a[$i]=uc($a[$i]);
        $seq{$id}{$species}{$pos}=$a[$i];
    }
    $control++;
    # last if($control++>10000);
}
close I;
print STDERR "$lst loaded...\n";

foreach my $id(sort keys %seq){
    print STDERR "$id\r";
    open O,"> $dir/$id.fa";
    open L,"> $dir/$id.log";
    my @head=sort keys %{$seq{$id}};
    open D,"> $dir/$id.debug";
    print D join "\t",@head,"\n";
    my %debug;
    foreach my $species(sort keys %{$seq{$id}}){
        my $nucl;
        my %codon;
        my $control=0;
        my $codon=0;
        my $strand = $gene{$id}{strand};
        if($strand eq "-"){
            my @pos = sort {$a<=>$b} keys %{$gene{$id}{pos}};
            my $len=scalar(@pos);
            my $x=$len % 3;
            for(my $i=0;$i<$x;$i++){
	delete $gene{$id}{pos}{$pos[$i]};
            }
        }
        my @pos=sort {$a<=>$b} keys %{$gene{$id}{pos}};
        foreach my $pos(@pos){
            if($control==3){
	$control=0;
	$codon++;
            }
            my $base="X";
            if(exists $seq{$id}{$species}{$pos}){
	$base=$seq{$id}{$species}{$pos};
            }
            if($base=~/^[-]+$/){
	$base="-";
            }
            else {
	$base=~s/-//g;
            }
            $codon{$codon}.=$base;
            $nucl.=$base;
            $control++;
        }
        my @codons=sort {$a<=>$b} keys %codon;
        if($strand eq "-"){
            $nucl=~tr/ATCGRYMK/TAGCYRKM/;
            $nucl=reverse($nucl);
            @codons=reverse(@codons);
        }
        print O ">$species\n$nucl\n";
        pop @codons;
        foreach my $i(@codons){
            my $codon_code=$codon{$i};
            if($strand eq "-"){
	$codon_code=~tr/ATCGRYMK/TAGCYRKM/;
	$codon_code=reverse($codon_code);
            }
            $debug{$i}{$species}=$codon_code;
            if($codon_code eq "TAA" || $codon_code eq "TAG" || $codon_code eq "TGA"){
	print L "$id\t$species\t$i\t$codon_code\tstop_codon\n";
	next;
            }
            $codon_code=~s/-//g;
            my $len=length($codon_code);
            if($len % 3 != 0){
	print L "$id\t$species\t$i\t$codon_code\tframeshift\n";
            }
            elsif($len > 3 && $len & 3 == 0){
	my @base=split(/\s+/,$codon_code);
	for(my $i=0;$i<@base;$i+=3){
	    my $new_codon_code=$base[$i].$base[$i+1].$base[$i+2];
	    if($new_codon_code eq "TAA" || $new_codon_code eq "TAG" || $new_codon_code eq "TGA"){
	        print L "$id\t$species\t$i\t$codon_code\tstop_codon\tinsert\n";
	    }
	}
            }
        }
    }
    close O;
    close L;
    foreach my $i(sort {$a<=>$b} keys %debug){
        my @debug=($i);
        foreach my $species(@head){
            push @debug,$debug{$i}{$species};
        }
        print D join "\t",@debug,"\n";
    }
    close D;
}
print STDERR "\nDone\n";

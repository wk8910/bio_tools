#! /usr/bin/env perl
use strict;
use warnings;

my $gff="nc_ref.gff";
my $lst="bovine.sixSpecies.maf.lst.gz";
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
    foreach my $species(sort keys %{$seq{$id}}){
        my $nucl;
        foreach my $pos(sort {$a<=>$b} keys %{$gene{$id}{pos}}){
            my $base="-";
            if(exists $seq{$id}{$species}{$pos}){
	$base=$seq{$id}{$species}{$pos};
            }
            $nucl.=$base;
        }
        my $strand = $gene{$id}{strand};
        if($strand eq "-"){
            $nucl=~tr/ATCGRYMK/TAGCYRKM/;
            $nucl=reverse($nucl);
        }
        print O ">$species\n$nucl\n";
    }
    close O;
}
print STDERR "\nDone\n";

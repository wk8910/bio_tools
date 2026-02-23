#! /usr/bin/env perl
use strict;
use warnings;

my $one2one="one2one.txt"; # one to one ortholougs from orthomcl results
my $cds_dir="cds"; # directory of cds files of each species
my $outdir="clusters";
`mkdir $outdir` if(!-e $outdir);

my %hash;
my @cds=<$cds_dir/*>;
foreach my $cds(@cds){
    $cds=~/(\w+)\.cds$/;
    my $species=$1;
    open I,"perl ~/bio_tools/00.scripts/read_fasta.pl $cds |";
    while (my $id=<I>) {
        chomp $id;
        $id=$species."|".$id;
        my $seq=<I>;
        chomp $seq;
        $hash{$id}=$seq;
    }
    close I;
}

open I,"< $one2one";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my $cluster_id=$a[0];
    $cluster_id=~s/://g;
    open O,"> $outdir/$cluster_id.fa";
    for(my $i=1;$i<@a;$i++){
        my $id=$a[$i];
        if(!exists $hash{$id}){
            die "$id\n";
        }
        my $seq=$hash{$id};
        print O ">$id\n$seq\n";
    }
    close O;
}
close I;

#! /usr/bin/env perl
use strict;
use warnings;

my $indir="genes";
my $outdir="result";
my $kaks_calculator="/home/share/users/wangkun2010/software/kaks_calculator/KaKs_Calculator2.0/bin/Linux/KaKs_Calculator";
`mkdir $outdir` if(!-e $outdir);

my %combination;
$combination{ds}{ss}=1;
$combination{ds}{gac}=1;
$combination{ds}{pol}=1;
$combination{ds}{tor}=1;
$combination{ss}{gac}=1;
$combination{ss}{pol}=1;
$combination{ss}{tor}=1;

my @fa=<$indir/*>;

open L,"> $0.sh";
foreach my $fa(@fa){
    $fa=~/\/([^\/]+)$/;
    my $id=$1;
    `mkdir $outdir/$id` if(!-e "$outdir/$id");
    $/=">";
    my $file="$fa/cds.fa";
    open(I,"< $file");
    my %hash;
    while (<I>) {
        chomp;
        my @lines=split("\n",$_);
        next if(@lines==0);
        my $id=shift @lines;# the name of fasta is $id
        $id=~/^(\S+)/;
        $id=$1;
        my $seq=join "",@lines;# the sequence of fasta is $seq
        $hash{$id}=$seq;
    }
    close I;
    $/="\n";

    foreach my $id1(sort keys %combination){
        foreach my $id2(sort keys %{$combination{$id1}}){
            my $new_id=$id."_".$id1."_".$id2;
            my $out_axt="$outdir/$id/kaks.${id1}_${id2}.axt";
            open O,"> $out_axt";
            print O "$new_id\n$hash{$id1}\n$hash{$id2}\n";
            print L "$kaks_calculator -i $out_axt -o $out_axt.kaks -m GMYN\n";
            close O;
        }
    }
}
close L;

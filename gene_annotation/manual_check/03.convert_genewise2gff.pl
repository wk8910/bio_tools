#! /usr/bin/env perl
use strict;
use warnings;

my $file=shift;
$file=~/^([^\.]+)/;
my $id=$1;
my $out_prefix="${id}_result";
open I,"< $file";
$/="//";
my @lines=<I>;
my @cds=split(/\n/,$lines[2]);
my @pep=split(/\n/,$lines[1]);
my @gff=split(/\n/,$lines[3]);
open O,"> $out_prefix.cds";
foreach my $line(@cds){
    next if($line=~/^\s*$/);
    next if($line=~/^\/\//);
    chomp $line;
    if($line=~/^>/){
        $line=">$id";
    }
    print O "$line\n";
}
close O;
open O,"> $out_prefix.pep";
foreach my $line(@pep){
    next if($line=~/^\s*$/);
    next if($line=~/^\/\//);
    chomp $line;
    if($line=~/^>/){
        $line=">$id";
    }

    print O "$line\n";
}
close O;
open O,"> $out_prefix.gff";
foreach my $line(@gff){
    next if($line=~/^\s*$/);
    next if($line=~/^\/\//);
    chomp $line;
    # print O "$line\n";
    my @a=split(/\s+/,$line);
    next if($a[2]=~/intron/);
    $a[8]="ID=$id;Parent=$id;";
    if($a[3]>$a[4]){
        my $tmp=$a[3];
        $a[3]=$a[4];
        $a[4]=$tmp;
    }
    if($a[2]=~/match/){
        $a[2]="gene";
        my $line1=join "\t",@a;
        print O "$line1\n";
        $a[2]="mRNA";
        my $line2=join "\t",@a;
        print O "$line2\n";
    }
    else {
        $a[2]="CDS";
        my $line1=join "\t",@a;
        print O "$line1\n";
    }
}
close O;
$/="\n";
close I;

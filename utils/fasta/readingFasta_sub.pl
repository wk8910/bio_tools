#! /usr/bin/env perl
use strict;
use warnings;

my $file=shift;

&read_fasta($file);

sub process_fasta{
    my ($id,$seq)=@_;
    $id=~/^(\S+)/;
    $id=$1;
    my $len=length($seq);
    print "$id\t$len\n";
}

sub read_fasta{
    my $fa=shift;
    open I,"< $fa";
    my $light=0;
    my $id="";
    my $seq="";
    while (<I>) {
        chomp;
        if(/^>(.*)/){
            if($id){
	&process_fasta($id,$seq);
            }
            $id=$1;
            $seq="";
        }
        else{
            $seq.=$_;
        }
    }
    &process_fasta($id,$seq);
    close I;
}

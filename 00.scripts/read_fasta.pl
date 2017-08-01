#! /usr/bin/env perl
use strict;
use warnings;

my $file=shift;

&read_fasta($file);

sub process_fasta{
    my ($id,$seq)=@_;
    print "$id\n$seq\n";
}

sub read_fasta{
    my $fa=shift;
    open I,"< $fa";
    my $light=0;
    my $id="";
    my $seq="";
    my $num=0;
    while (<I>) {
        chomp;
        if(/^>(.*)/){
            $num++;
            if($id){
	&process_fasta($id,$seq);
            }
            $id=$1;
            if(!$id){
	print STDERR "WARNING: The $num sequence has no id!\n";
	$id="noname_$num";
            }
            $seq="";
        }
        else{
            $seq.=$_;
        }
    }
    &process_fasta($id,$seq);
    close I;
}

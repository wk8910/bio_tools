#! /usr/bin/env perl
use strict;
use warnings;

my $txt="query.ko";
my $html="kaas_main.html";
my $out="gene.path";

my %kegg;
my %info;
open I,"< $html";
while (<I>) {
    chomp;
    next unless(/(ko\d+)/);
    my $path=$1;
    /([^<>]+)\<\/p\>$/;
    my $info=$1;
    $info{$path}=$info;
    while (/(K\d{5})/g) {
        my $ko=$1;
        $kegg{$ko}{$path}=1;
    }
}
close I;

open O,"> $out";
open I,"< $txt";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    next if(@a==1);
    my ($id,$ko)=@a;
    if(exists $kegg{$ko}){
        foreach my $path(keys %{$kegg{$ko}}){
            my $info=$info{$path};
            print O "$id\t$path\t$info\n";
        }
    }
    else{
        print "$ko" if($ko eq "K00022");
        # print "$ko\n";
    }
}
close I;
close O;

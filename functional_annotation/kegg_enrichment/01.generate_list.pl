#! /usr/bin/env perl
use strict;
use warnings;

my $list="report_run1.cafe";
my $group="mclOutput";
my $ref="sti";
my $background="background.lst"; # output file

open I,"< $list";
while (<I>) {
    next unless(/'ID'\s+'Newick'/);
    last;
}
my %hash;
my %status;
while (<I>) {
    chomp;
    /^(\w+).*ds_(\d+):[\d\.]+\)100_(\d+):/;
    my ($id,$ds,$anc)=($1,$2,$3);
    # print "$ds\t$anc\n";
    my $status;
    if($ds<$anc){
        $status="decrease";
    }
    elsif ($ds>$anc) {
        $status="increase";
    }
    next if(!$status);
    $status{$status}++;
    $hash{$id}=$status;
}
close I;

my %fh;
my @status=keys %status;
foreach my $status(@status){
    open $fh{$status},"> $status.lst";
}

open I,"< $group";
my $i=0;
open O,"> $background";
while (<I>) {
    $i++;
    my @a=split(/\s+/);
    my @genes;
    foreach my $gene(@a){
        $gene=~/^([^|]+)\|(\w+)/;
        my ($species,$geneid)=($1,$2);
        next unless($species eq $ref);
        print O "$geneid\n";
        push @genes,$geneid;
    }

    if(exists $hash{$i}){
        my $status=$hash{$i};
        foreach my $geneid(@genes){
            $fh{$status}->print("$geneid\n");
        }
    }
}
close I;
close O;

foreach my $status(keys %fh){
    close $fh{$status};
}

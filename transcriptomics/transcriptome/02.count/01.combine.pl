#! /usr/bin/env perl
use strict;
use warnings;

my $one2one="one2one.txt";
my $out="$0.txt";

my %group;
open I,"< $one2one";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my $cluster_id=$a[0];
    $cluster_id=~s/://;
    for(my $i=1;$i<@a;$i++){
        $a[$i]=~/^([^\|]+)\|(.*)/;
        my ($species,$id)=($1,$2);
        $group{$species}{$id}=$cluster_id;
    }
}
close I;

my @count=<*/02.collect.pl.txt>;
my %count;
my %sample;
foreach my $count(@count){
    $count=~/^(.{3})/;
    my $species=$1;
    # if($count=~/^ds/){
    #     $species="ds";
    # }
    open I,"< $count";
    my $head=<I>;
    chomp $head;
    my @head=split(/\s+/,$head);
    while (<I>) {
        chomp;
        my @a=split(/\s+/);
        my $id=shift @a;
        next unless(exists $group{$species}{$id});
        my $cluster_id=$group{$species}{$id};
        for(my $i=0;$i<@a;$i++){
            my $sample=$head[$i];
            # if($sample=~/^([^_]+)_/){
            # 	$sample=$1;
            # 	# print "$sample\n";
            # }
            $sample="$species.".$sample;
            $sample{$sample}++;
            $count{$cluster_id}{$sample}=$a[$i];
        }
    }
    close I;
}

open O,"> $out";
my @sample=keys %sample;
print O join "\t",@sample,"\n";
foreach my $cluster_id(sort keys %count){
    my @line=($cluster_id);
    foreach my $sample(@sample){
        my $num=0;
        if(exists $count{$cluster_id}{$sample}){
            $num=$count{$cluster_id}{$sample};
        }
        push @line,$num;
    }
    print O join "\t",@line,"\n";
}
close O;

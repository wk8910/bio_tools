#! /usr/bin/env perl
use strict;
use warnings;

my @root=("out11","out2");
@root=sort @root;
my $tag=join " ",@root;

my $tree="origin.tre";
open I,"< $tree";
open O,"> $0.tre";
open L,"> $0.log";
my $seq=0;
while(<I>){
    chomp;
    $seq++;
    my @elements=split(/\s+/);
    my @a=split("",$elements[2]);
    my $line=$_;
    my $count=0;
    my @part;
    my $num=0;
    for(my $i=1;$i<@a;$i++){
        $part[$num].=$a[$i];
        if($a[$i] eq "("){
            $count++;
        }
        if($a[$i] eq ")"){
            $count--;
        }
        if($count==0 && $a[$i]=~/[,;]/){
            $num++;
        }
    }
    # print join "\n",@part,"\n";
    my $light=0;
    foreach my $part(@part){
        my @member;
        while($part=~/(\w+)/g){
            my $x = $1;
            next unless($x=~/[a-z]/);
            # print "$x\n";
            push @member,$x;
        }
        @member = sort @member;
        my $test = join " ",@member;
        # print "$test\n";
        if($tag eq $test){
            $light=1;
        }
    }
    if($light == 1){
        print O "$line\n";
    }
    print L "$elements[0]\t$elements[1]\t$light\n";
    # last;
}
close I;
close O;

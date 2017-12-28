#! /usr/bin/env perl
use strict;
use warnings;

my $tree="clean.tre";
my $log="01.filter.pl.log";
my $type="clean.tre.count";

my @tree;
open I,"< $tree";
while (<I>) {
    chomp;
    push @tree,$_;
}
close I;

my %type;
open I,"< $type";
my $x=0;
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    $x++;
    my $t="class".$x;
    $type{$a[0]}=$t;
    last if($x>10);
}
close I;

open I,"< $log";
open O,"> $0.txt";
my $light=0;
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($chr,$pos,$info)=@a;
    if($info > 0){
        $light++;
        my $phy=$tree[$light-1];
        my $test_phy=&sort_tree($phy);
        # print "$test_phy\n";
        my $class="other";
        if(exists $type{$test_phy}){
            $class=$type{$test_phy};
        }
        print O "$chr\t$pos\t$class\t$phy\n";
    }
    else {
        print O "$chr\t$pos\tNA\tNA\n";
    }
}
close I;
close O;

sub sort_tree{
    my $tree=shift;
    $tree=~s/:[\d\.]+//g;
    $tree=~s/;//;
    my @parts=&split_tree($tree);
    foreach my $part(@parts){
        # print "$part\n";
        if($part=~/\(/){
            $part=&sort_tree($part);
        }
    }
    my @new_parts=sort(@parts);
    my $new_tree=join ",",@new_parts;
    $new_tree="(".$new_tree.")";
    return($new_tree);
}

sub split_tree{
    my $tree=shift;
    my @part;

    if($tree=~/^\(/){
        $tree=~s/^\(//;
        $tree=~s/\)$//;
    }

    my @a=split(//,$tree);
    my $left=0;
    my $right=0;
    my $flag=0;
    my $part=0;
    for(my $i=0;$i<@a;$i++){
        if($a[$i]=~/\(/){
            $left++;
        }
        if($a[$i]=~/\)/){
            $right++;
        }
        if($left==$right){
            $flag=1;
        }
        if($flag==1 && $a[$i]=~/,/){
            $part++;
            $flag=0;
            next;
        }
        last if($left<$right);
        $part[$part].=$a[$i];
    }
    return(@part);
}

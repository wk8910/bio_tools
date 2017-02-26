#! /usr/bin/env perl
# only useful for rooted tree
use strict;
use warnings;

my $treefile=shift;
die "Usage: $0 <treefile>\none tree in one line\n" if(!-e "$treefile");

open I,"< $treefile" or die "Cannot open $treefile";
open O,"> $treefile.unite.tre" or die "Cannot create $0.unite.tre";
while(my $tre=<I>){
    chomp $tre;
    $tre=~s/[\d\.\:]+//g;
    my $tre_bak=$tre;
    # print "$tre";
    my $level=0;
    while($tre=~/\(/){
	$level++;
	$tre=~s/(\([^()]+\))//g;
    }
    $tre=$tre_bak;
    my $temp_tre=$tre;
    for(my $i=1;$i<=$level;$i++){
	my $plus=(1/$level)*$i;
	while($tre=~/(\([^()]+\))/g){
	    my $node=$1;
	    $node=~/\(([^,]+),([^,]+)\)/;
	    my ($left,$right)=($1,$2);

	    my $left_length=&get_tree_length($left);
	    $left_length=$plus-$left_length;

	    my $right_length=&get_tree_length($right);
	    $right_length=$plus-$right_length;

	    my $new_node="[".$left.":$left_length"."#".$right.":$right_length]";
	    $temp_tre=~s/\Q$node\E/$new_node/;
	}
	$tre=$temp_tre;
    }
    $tre=~tr/\#\[\]/,(\)/;
    print O "$tre\n";
}
close I;
close O;

sub get_tree_length{
    my $tree=shift;
    my $total_len=0;
    if($tree=~/(.*)\:([\d\.]+)$/){
	my ($res_tree,$len)=($1,$2);
	$total_len+=$len;
	if($res_tree=~/^\[/){
	    my $res_len=&get_tree_length($res_tree);
	    $total_len+=$res_len;
	}
	return($total_len);
    }
    elsif($tree=~/\]$/){
	my @trees=&split_tree($tree);
	my $first_tree=$trees[0];
	my $len=&get_tree_length($first_tree);
	return($len);
    }
    else{
	return(0);
    }
}

sub split_tree{
    my $tree=shift;
    my @part;

    if($tree=~/^\[/){
	$tree=~s/^\[//;
	$tree=~s/\]$//;
    }

    my @a=split(//,$tree);
    my $left=0;
    my $right=0;
    my $flag=0;
    my $part=0;
    for(my $i=0;$i<@a;$i++){
	if($a[$i]=~/\[/){
	    $left++;
	}
	if($a[$i]=~/\]/){
	    $right++;
	}
	if($left==$right){
	    $flag=1;
	}
	if($flag==1 && $a[$i]=~/#/){
	    $part++;
	    $flag=0;
	    next;
	}
	last if($left<$right);
	$part[$part].=$a[$i];
    }
    return(@part);
}

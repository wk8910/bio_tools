#! /usr/bin/env perl
use strict;
use warnings;

my $order="order.txt";
my $poplst="pop.lst";
my $in="03.ibd_sta.pl.txt";
my $out="$0.txt";

my %order;
open I,"< $order";
my $seq=64;
while(<I>){
    chomp;
    $seq++;
    # my $groupid="0" x (2-length($seq));
    # $groupid.=$seq;
    my $groupid=chr($seq);
    # my $groupid=$seq;
    $order{$_}=$groupid;
}
close I;

my %new_name;
my $x=10;
open I,"< $poplst";
while(<I>){
    chomp;
    $x++;
    my @a=split(/\s+/);
    my ($id,$pop)=@a;
    my $prefix=$order{$pop};
    my $new_id=$prefix.".".$id;
    $new_name{$id}=$new_id;
}
close I;

open I,"< $in";
open O,"> $out";
my $head=<I>;
chomp $head;
$head=~s/^\s*//;
my @head=split(/\s+/,$head);
for(my $i=0;$i<@head;$i++){
    if(exists $new_name{$head[$i]}){
	$head[$i]=$new_name{$head[$i]};
    }
}
my %result;
while(<I>){
    chomp;
    my @a=split(/\s+/);
    if(exists $new_name{$a[0]}){
	$a[0]=$new_name{$a[0]};
    }
    my $x=$a[0];
    for(my $i=1;$i<@a;$i++){
	my $y=$head[$i-1];
	$result{$x}{$y}=$a[$i];
    }
}

my @order=sort @head;
print O join "\t",@order,"\n";
foreach my $x(@order){
    my @line=($x);
    foreach my $y(@order){
	push @line,$result{$x}{$y};
    }
    print O join "\t",@line,"\n";
}

close O;
close I;

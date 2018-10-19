#! /usr/bin/env perl
use strict;
use warnings;

my $fasta=shift;

if($fasta=~/.gz$/){
    open I,"zcat $fasta |";
}
else{
    open I,"< $fasta";
}
$fasta=~/\/([^\/]+)$/;
my $id=$1;
$id=~/^([\.]+)/;
$id=$1;
print "$id\t";
my ($num,$sum)=(0,0);;
my @len;
while(my $l1=<I>){
    my $l2=<I>;
    $num++;
    chomp $l1;
    chomp $l2;

    if($l1!~/^>/){
        my $line_num=$num*2;
        die "line $line_num error: $l1\n$l2\n";
    }
    my $len=length($l2);
    push @len,$len;
    $sum+=$len;
}
close I;

&statistics(\@len,$num,$sum);

sub statistics{
    my ($array,$num,$sum)=@_;
    my @a=@{$array};

    my @sort_a=sort {$b<=>$a} @a;
    my $mean_len=$sum/$num;
    my $max_len=$sort_a[0];
    my $medium_len=$sort_a[int($num/2+0.5)];
    my $temp=0;
    my $n50=0;
    my $n50_num=0;
    foreach my $len(@sort_a){
        $temp+=$len;
        $n50_num++;
        if($temp/$sum>0.5){
            $n50=$len;
            last;
        }
    }
    print "$sum\t$num\t$mean_len\t$n50\t$n50_num\t$medium_len\t$max_len\n";
}


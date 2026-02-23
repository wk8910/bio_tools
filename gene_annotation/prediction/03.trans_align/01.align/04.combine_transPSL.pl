#! /usr/bin/env perl
use strict;
use warnings;

my $dir="alignment";
my @psl=<$dir/*/*.psl>;

open O,"> $0.psl";
foreach my $psl(@psl){
    open I,"< $psl";
    for(my $i=0;$i<5;$i++){
        <I>;
    }
    my %hash;
    my $num=0;
    my $pre_qid="NA";
    while (<I>) {
        chomp;
        # print O "$_\n";
        my @a=split(/\s+/);
        my $match=$a[0];
        my $mis_match=$a[1];
        my $qsize=$a[10];
        my $qid=$a[9];
        if($qid ne $pre_qid){
            $num=0;
        }
        $num++;
        $pre_qid=$qid;
        next if($match/$qsize < 0.5);
        my $score=($match/(($mis_match+10)/($match+$mis_match)));
        $hash{$qid}{$num}{line}=$_;
        $hash{$qid}{$num}{score}=$score;
    }
    foreach my $qid(sort keys %hash){
        foreach my $num(sort {$hash{$qid}{$b}{score} <=> $hash{$qid}{$a}{score}} keys %{$hash{$qid}}){
            print O "$hash{$qid}{$num}{line}\n";
            last;
        }
    }
    close I;
}
close O;

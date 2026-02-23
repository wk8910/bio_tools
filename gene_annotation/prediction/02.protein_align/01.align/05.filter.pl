#! /usr/bin/env perl
use strict;
use warnings;

my $psl="04.combine.pl.psl";

my %hash;
my $num=0;
open I,"< $psl";
my %len;
while (<I>) {
    chomp;
    $num++;
    my @a=split(/\s+/);
    my ($id,$match,$mismatch,$raw_len)=($a[9],$a[0],$a[1],$a[10]);
    my $map_ratio=$match/$raw_len;
    my $total_ratio=($match+$mismatch)/$raw_len;
    $hash{$id}{$num}{info}=$_;
    $hash{$id}{$num}{map_ratio}=$map_ratio;
    $hash{$id}{$num}{total_ratio}=$total_ratio;
    $len{$id}=$raw_len;
}
close I;

open O,"> $0.psl";
open S,"> $0.sta";
# open T,"> $0.test";
foreach my $id(sort keys %hash){
    my $i=0;
    my $first_map_ratio="NA";
    # my @line=($id,$len{$id});
    foreach my $num(sort {$hash{$id}{$b}{map_ratio}<=>$hash{$id}{$a}{map_ratio}} keys %{$hash{$id}}){
        my $map_ratio=$hash{$id}{$num}{map_ratio};
        my $total_ratio=$hash{$id}{$num}{total_ratio};
        my $percent=$map_ratio/$total_ratio;
        $i++;
        # push @line,$map_ratio;
        if($i==1){
            $first_map_ratio=$map_ratio;
        }
        else {
            if($first_map_ratio<0.2){ # WARNING: arbitrary parameter
	last;
            }
            if($map_ratio/$first_map_ratio<0.8){ # WARNING: arbitrary parameter
	last;
            }
        }
        print O "$hash{$id}{$num}{info}\n";
        print S "$id\t$len{$id}\t$hash{$id}{$num}{map_ratio}\t$hash{$id}{$num}{total_ratio}\t$percent\n";
    }
    # my $line=join "\t",@line;
    # print T "$line\n";
}
close S;
close O;
# close T;

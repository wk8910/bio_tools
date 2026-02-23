#! /usr/bin/env perl
use strict;
use warnings;

my $psl="05.filter.pl.psl";
my $out="$0.psl";

open O,"> $out";
open I,"< $psl";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($match,$mis_match,$rep_match,$N_s,$q_gap_count,$q_gap_base,$t_gap_count,$t_gap_base,$strand,$query,$q_size,$q_start,$q_end,$target,$t_size,$t_start,$t_end,$block_count,$block_sizes,$q_starts,$t_starts)=@a;
    $strand=~s/^\+//;
    my @b=split(/,/,$block_sizes);
    my $new_block_sizes;
    for(my $i=0;$i<@b;$i++){
        $b[$i]=$b[$i]*3;
        $new_block_sizes.=$b[$i];
        $new_block_sizes.=",";
    }
    my $new_t_starts=$t_starts;
    my $new_q_starts=$q_starts;
    if($strand eq "-"){
        my @c=split(/,/,$t_starts);
        for(my $i=0;$i<@c;$i++){
            $c[$i]=$t_size-$c[$i]-$b[$i];
        }
        @c=reverse(@c);
        $new_t_starts=join ",",@c;
        $new_t_starts.=",";
        @b=reverse(@b);
        $new_block_sizes=join ",",@b;
        $new_block_sizes.=",";
        my @d=split(/,/,$q_starts);
        @d=reverse(@d);
        $new_q_starts=join ",",@d;
        $new_q_starts.=",";
    }
    my @line=($match,$mis_match,$rep_match,$N_s,$q_gap_count,$q_gap_base,$t_gap_count,$t_gap_base,$strand,$query,$q_size,$q_start,$q_end,$target,$t_size,$t_start,$t_end,$block_count,$new_block_sizes,$new_q_starts,$new_t_starts);
    my $line=join "\t",@line;
    print O "$line\n";
}
close I;
close O;

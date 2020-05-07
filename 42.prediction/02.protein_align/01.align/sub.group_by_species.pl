#! /usr/bin/env perl
use strict;
use warnings;

my $psl=shift;
my $out="$psl.group.psl";
my $point_size=50000;

my %info;
my $hit=0;
my $group_id=0;
my %point_group;

my $parent_node=0;
my %point_connection;
my %group;
open I,"< $psl";
while (<I>) {
    chomp;
    next if(/^#/);
    next if(/^\s*$/);
    $hit++;
    $info{$hit}=$_;
    my @a=split(/\s+/);
    my ($match,$mis_match,$rep_match,$N_s,$q_gap_count,$q_gap_base,$t_gap_count,$t_gap_base,$strand,$query,$q_size,$q_start,$q_end,$target,$t_size,$t_start,$t_end,$block_count,$block_sizes,$q_starts,$t_starts)=@a;
    if(!$t_starts){
        die "@a\n";
    }
    my @pos=&get_pos($t_starts,$block_sizes);
    my @point;
    for(my $i=0;$i<@pos;$i+=2){
        my $temp_s=$pos[$i];
        my $temp_e=$pos[$i+1];
        my $point_s=int($temp_s/$point_size)*$point_size;
        my $point_e=int($temp_e/$point_size)*$point_size;
        for(my $point_i=$point_s;$point_i<=$point_e;$point_i+=$point_size){
            my $point="$target|$strand|$point_i";
            push @point,$point;
        }
    }
    my $light=0;
    my $group_here="NA";
    my %connection_test;
    foreach my $point(@point){
        if(exists $point_group{$point}){
            $group_here=$point_group{$point};
            $connection_test{$group_here}++;
            $light=1;
            # last;
        }
    }
    if(keys %connection_test > 1){
        $parent_node++;
        my @temp=keys %connection_test;
        # print "initial:\t$parent_node\t@temp\n";
        foreach my $child_node(keys %connection_test){
            next if($child_node eq $parent_node);
            $point_connection{$child_node}{$parent_node}=1;
            # print STDERR "connect\t$child_node\t$parent_node\n";
        }
    }
    if($light==0){
        $group_id++;
        # print STDERR "group $group_id created...\r";
        $group_here=$group_id;
    }
    for(my $i=0;$i<@pos;$i+=2){
        my $temp_s=$pos[$i];
        my $temp_e=$pos[$i+1];
        my $point_s=int($temp_s/$point_size)*$point_size;
        my $point_e=int($temp_e/$point_size)*$point_size;
        for(my $point_i=$point_s;$point_i<=$point_e;$point_i+=$point_size){
            my $point="$target|$strand|$point_i";
            if(!exists $point_group{$point}){
	$point_group{$point}=$group_here;
            }
            $group{$group_here}{$hit}++;
            # print STDERR "hit: $hit\t$group_here\t$point\n";
        }
    }
}
close I;

my $new_id=0;


my %final_connection=&connect(%point_connection);

foreach my $group_id(keys %group){
    if(exists $final_connection{$group_id}){
        # print STDERR "group id $group_id\n";
        my @new_id=keys $final_connection{$group_id};
        if(@new_id == 2){
            die "@new_id\n";
        }
        my $new_id=$new_id[0];
        next if($group_id eq $new_id);
        my @hit=keys %{$group{$group_id}};
        foreach my $hit(@hit){
            $group{$new_id}{$hit}++;
        }
        delete $group{$group_id};
    }
}

open O,"> $out";
my $group_num=0;
foreach my $group_id(sort keys %group){
    my @hit=sort keys %{$group{$group_id}};
    # print "## $group_id\n";
    &resolve_hit(@hit);
}
close O;

sub resolve_hit{
    my @hit=@_;
    my %score;
    if(@hit<1){
        return();
    }
    elsif(@hit==1){
        my $hit=$hit[0];
        $group_num++;
        print O "## $group_num\n";
        print O "$info{$hit}\n";
        return();
    }
    foreach my $hit(@hit){
        my @a=split(/\s+/,$info{$hit});
        my ($match,$mis_match,$rep_match,$N_s,$q_gap_count,$q_gap_base,$t_gap_count,$t_gap_base,$strand,$query,$q_size,$q_start,$q_end,$target,$t_size,$t_start,$t_end,$block_count,$block_sizes,$q_starts,$t_starts)=@a;
        my $score=($match/(($mis_match+10)/($match+$mis_match))); # WARNING: arbitrary score definition
        # print "score:".int($score+0.5)."\t$info{$hit}\n";
        $score{$hit}=$score;
    }
    my @sorted_hit=sort {$score{$b}<=>$score{$a}} keys %score;
    my $king_hit=shift @sorted_hit;
    my $info1=$info{$king_hit};
    my @info1=split(/\s+/,$info1);
    my ($match_1,$mis_match_1,$rep_match_1,$N_s_1,$q_gap_count_1,$q_gap_base_1,$t_gap_count_1,$t_gap_base_1,$strand_1,$query_1,$q_size_1,$q_start_1,$q_end_1,$target_1,$t_size_1,$t_start_1,$t_end_1,$block_count_1,$block_sizes_1,$q_starts_1,$t_starts_1)=@info1;
    $group_num++;
    print O "## $group_num\n";
    print O "$info1\n";
    my @left_hit;
    foreach $hit(@sorted_hit){
        my $info2=$info{$hit};
        my @info2=split(/\s+/,$info2);
        my ($match_2,$mis_match_2,$rep_match_2,$N_s_2,$q_gap_count_2,$q_gap_base_2,$t_gap_count_2,$t_gap_base_2,$strand_2,$query_2,$q_size_2,$q_start_2,$q_end_2,$target_2,$t_size_2,$t_start_2,$t_end_2,$block_count_2,$block_sizes_2,$q_starts_2,$t_starts_2)=@info2;
        if($t_start_1 > $t_end_2 || $t_start_2 > $t_end_1){
            push @left_hit,$hit;
        }
        else {
            my @pos1=&get_pos($t_starts_1,$block_sizes_1);
            my @pos2=&get_pos($t_starts_2,$block_sizes_2);
            my $light=1;
            for(my $i=0;$i<@pos1;$i+=2){
	for(my $j=0;$j<@pos2;$j+=2){
	    my $s1=$pos1[$i];
	    my $e1=$pos1[$i+1];
	    my $s2=$pos2[$j];
	    my $e2=$pos2[$j+1];
	    if($s1<=$e2 && $s2<=$e1){
	        $light=0;
	        # last;
	        print O "#$info2\n";
	        last;
	    }
	}
	last if($light==0);
            }
            if($light==1){
	push @left_hit,$hit;
            }
        }
    }
    if(@left_hit==0){
        return();
    }
    else {
        &resolve_hit(@left_hit);
    }
}

sub get_pos{
    my ($t_starts,$block_sizes)=@_;
    $t_starts=~s/,$//;
    $block_sizes=~s/,$//;
    my @t_starts=split(",",$t_starts);
    my @block_sizes=split(",",$block_sizes);
    my @pos;
    for(my $i=0;$i<@t_starts;$i++){
        my $start=$t_starts[$i];
        my $block_sizes=$block_sizes[$i];
        my $end=$start+$block_sizes-1;
        push @pos,($start,$end);
    }
    return(@pos);
}

sub connect{
    my %connection=@_;
    my %update_node;
    my $light=0;
    my %new_connection;
    foreach my $child_node(keys %connection){
        my @parent_node=keys %{$connection{$child_node}};
        if(@parent_node>1){
            $light=1;
            my $x_id="NA";
            foreach my $parent_node(@parent_node){
	if(!exists $update_node{$parent_node}){
	    if($x_id eq "NA"){
	        $new_id++;
	        $x_id="n$new_id";
	        $update_node{$parent_node}=$x_id;
	    }
	    elsif ($x_id ne "NA") {
	        $update_node{$parent_node}=$x_id;
	    }
	}
            }
        }
    }
    foreach my $child_node(keys %connection){
        foreach my $parent_node(keys %{$connection{$child_node}}){
            my $new_node=$parent_node;
            if(exists $update_node{$parent_node}){
	$new_node=$update_node{$parent_node};
            }
            $new_connection{$child_node}{$new_node}++;
        }
    }
    if($light==0){
        return(%new_connection);
    }
    else{
        &connect(%new_connection);
    }
}

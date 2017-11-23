#! /usr/bin/env perl
use strict;
use warnings;

my %black_list;
if(-e "black.lst"){
    open I,"< black.lst";
    while(<I>){
        chomp;
        $black_list{$_}=1;
    }
    close I;
}

my %kin;
open(I,"< snp.kin0");
<I>;
while(<I>){
    chomp;
    chomp;
    my @a=split(/\s+/);
    my ($id1,$id2)=sort($a[0],$a[2]);
    next if(exists $black_list{$id1} or exists $black_list{$id2});
    my $value=$a[-1];
    my $bar_code=$id1."-".$id2;
    $kin{$id1}{$id2}=$value;
    $kin{$id2}{$id1}=$value;
}
close I;

&filter(0.354,"04.duplicate.0.354.retainInd.txt");
&filter(0.177,"04.1st-degree.0.177.retainInd.txt");
&filter(0.0884,"04.2nd-degree.0.0884.retainInd.txt");
&filter(0.0442,"04.3rd-degree.0.0442.retainInd.txt");

sub filter{
    my $criteria=shift;
    my $out=shift;
    my @selected=keys %kin;
    my $count=&count($criteria,@selected);
    while($count>0){
	print "$count unfit relationship\n";
	@selected=&delete_ind($criteria,@selected);
	$count=&count($criteria,@selected);
    }
    open(O,"> $out");
    foreach my $ind(@selected){
	print O "$ind\n";
    }
    close O;
}

sub delete_ind{
    my $criteria=shift;
    my @sample=@_;
    my %sample;
    foreach my $id(@sample){
        $sample{$id}=1;
    }
    my %number;
    foreach my $id(keys %kin){
	next unless(exists $sample{$id});
	foreach my $pair(keys %{$kin{$id}}){
	    next unless(exists $sample{$pair});
	    my $value=$kin{$id}{$pair};
	    if($value >= $criteria){
		$number{$id}++;
	    }
	}
    }
    my @rank = sort {$number{$b} <=> $number{$a}} keys %number;
    my @potential_id;
    for(my $i=0;$i<@rank;$i++){
	my $temp_id=$rank[$i];
	my $number=$number{$temp_id};
	if($number == $number{$rank[0]}){
	    push @potential_id,$temp_id;
	}
    }
    # print STDERR "$number{$rank[0]}\n";
    # print STDERR "One of these individuals will be deleted:\n@potential_id\n";
    my %comparision;
    for(my $i=0;$i<@potential_id;$i++){
	my @x;
	my $temp_delete_id=$potential_id[$i];
	foreach my $id(keys %sample){
	    next if($id eq $temp_delete_id);
	    push @x,$id;                                                                                                                                                                
	}
	my $unfit_number=&count($criteria,@x);
	$comparision{$temp_delete_id}=$unfit_number;
	# print "TEST: $temp_delete_id\t$unfit_number\n";
    }
    @rank=sort {$comparision{$a} <=> $comparision{$b}} keys %comparision;
    my $delete_id=$rank[0];
    print STDERR "Delete $delete_id\n";
    my @new_sample;
    foreach my $id(keys %sample){
	next if($id eq $delete_id);
	push @new_sample,$id;
    }
    return(@new_sample);
}

sub count{
    my $criteria=shift;
    my @sample=@_;
    my %sample;
    my %number;
    foreach my $id(@sample){
	$sample{$id}=1;
    }
    foreach my $id(keys %kin){
	next unless(exists $sample{$id});
	foreach my $pair(keys %{$kin{$id}}){
	    next unless(exists $sample{$pair});
	    my $value=$kin{$id}{$pair};
	    if($value >= $criteria){                                                                                                                                                                        $number{$id}++;
            }                                                                                                                                                                               
	}
    }
    my $number = scalar(keys %number);
    return($number);
}

#! /usr/bin/env perl
use strict;
use warnings;

my $dir="fasta";
my $blastdir="$dir.blast_file";
my @pep=<$dir/*.pep>;

open O,"> $0.out";
my %record;
my %dict;
my %black;
for(my $i=0;$i<@pep;$i++){
    my $db=$pep[$i];
    $db=~/\/([^\/]+)\.pep$/;
    my $db_name=$1;
    my $num=0;
    my %temp;
    for(my $j=$i+1;$j<@pep;$j++){
        next if($i==$j);
        $num++;
        my $query=$pep[$j];
        $query=~/\/([^\/]+).pep$/;
        my $query_name=$1;
        my $blastout1="$blastdir/$db_name.$query_name.blast";
        if(!-e $blastout1){
            print STDERR "no $query $db $blastout1\n";
        }
        my $blastout2="$blastdir/$query_name.$db_name.blast";
        if(!-e $blastout2){
            print STDERR "no $db $query $blastout2\n";
        }
        my %hash;
        open I,"< $blastout1";
        while (<I>) {
            chomp;
            my @a=split(/\s+/);
            my ($qseq,$target,$evalue,$score)=($a[0],$a[1],$a[10],$a[11]);
            next if(exists $hash{$qseq});
            if($evalue>1e-10){
	$hash{$qseq}{target}="NA";
	next;
            }
            $hash{$qseq}{target}=$target;
        }
        close I;
        my %hash2;
        open I,"< $blastout2";
        while (<I>) {
            chomp;
            my @a=split(/\s+/);
            my ($qseq,$target,$evalue,$score)=($a[0],$a[1],$a[10],$a[11]);
            next if(exists $hash2{$qseq});
            $hash2{$qseq}{target}=$target;
            next if($evalue>1e-10);
            if(exists $hash{$target} && $hash{$target}{target} eq $qseq){
	my $left="$db_name.$qseq";
	my $right="$query_name.$target";
	my $root;
	if($i==0){
	    $root=$left;
	}
	elsif(exists $dict{$left}){
	    $root=$dict{$left};
	}
	else {
	    next;
	}
	$dict{$right}=$root;
	next if(exists $black{$root});
	my $light=1;
	if($i==0){
	    $record{$root}{$query_name}=$right;
	}
	else {
	    if(!exists $record{$root}{$query_name}){
	        $black{$root}++;
	        $light=0;
	    }
	    elsif($record{$root}{$query_name} ne $right) {
	        $black{$root}++;
	        $light=0;
	    }
	}
	if($light==1){
	    $temp{$root}{$query_name}=$right;
	}
            }
        }
        close I;
        foreach my $root(keys %temp){
            my $count=keys %{$temp{$root}};
            if($count ne $num){
	$black{$root}++;
            }
        }
        # last if($num>2);
    }
    # last;
}

open O,"> $0.out";
foreach my $root(sort keys %record){
    next if(exists $black{$root});
    my @line=($root);
    foreach my $query(sort keys %{$record{$root}}){
        push @line,$record{$root}{$query};
    }
    my $line=join "\t",@line;
    print O "$line\n";
}
close O;

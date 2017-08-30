#! /usr/bin/env perl
use strict;
use warnings;

my $node_tree="03.generate_seq.pl.tre";
my $fasta="03.generate_seq.pl.fa";
my $out="$0.txt";

open I,"< $node_tree";
my $line="";
while(<I>){
    chomp;
    $line.=$_;
}
close I;

my %hash;
&sort_tree($line);

my %seq;
open I,"perl /home/share/user/user101/bio_tools/00.scripts/read_fasta.pl $fasta |";
while(my $id=<I>){
    my $seq=<I>;
    chomp $id;
    chomp $seq;
    $seq{$id}=$seq;
}
close I;

open O,"> $out";
foreach my $root(sort keys %hash){
    my $node1=$hash{$root}{node1};
    my $node2=$hash{$root}{node2};

    my $root_seq=$seq{$root};
    my $seq1=$seq{$node1};
    my $seq2=$seq{$node2};
    my $diff1=&diff_count($root_seq,$seq1);
    my $diff2=&diff_count($root_seq,$seq2);
    my $diff3=&diff_count($seq1,$seq2);
    print O "$root between\t$node1:\t$diff1\tor\t$node2:\t$diff2\ttotal:$diff3\n";
}
close O;

sub diff_count{
    my ($seq1,$seq2)=@_;
    my @seq1=split(//,$seq1);
    my @seq2=split(//,$seq2);
    my $len1=length($seq1);
    my $len2=length($seq2);
    if($len1 ne $len2){
	die "the sequences must be aligned!\n$len1\t$len2\n"
    }
    my $count=0;
    for(my $i=0;$i<@seq1;$i++){
	my $base1=uc($seq1[$i]);
	my $base2=uc($seq2[$i]);
	next unless($base1=~/[ATCG]/ && $base2=~/[ATCG]/);
	if($base1 ne $base2){
	    $count++;
	}
    }
    return($count);
}

sub get_name{
    my $string=shift;
    $string=~/(\w+)$/;
    my $name=$1;
    return($name);
}

sub sort_tree{
    my $tree=shift;
    $tree=~s/;$//;
    my $root=&get_name($tree);
    my @parts=&split_tree($tree);
    my $node1=&get_name($parts[0]);
    my $node2=&get_name($parts[1]);
    # print "$node1\t$root\n$node2\t$root\n";
    $hash{$root}{node1}=$node1;
    $hash{$root}{node2}=$node2;
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

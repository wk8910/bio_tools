#! /usr/bin/env perl
use strict;
use warnings;

my $maf="alignment.maf"; # the first line must be complete genome and all should be forward strand, the second line must be fragment genome.

my %link;
my %completeGenome_len;
my %fragmentGenome_len;

my $total_len=0;
my $link_num=0;
open I,"< $maf";
my $control=0;
while(<I>){
    chomp;
    next if(/^#/);
    my @alignment;
    if(/^a/){
        push @alignment,"$_";
        while(<I>){
            chomp;
            if(/^\s*$/){
	last;
            }
            else{
	push @alignment,"$_";
            }
        }
    }
    my ($fragmentGenome_chr,$fragmentGenome_start,$fragmentGenome_end,$fragmentGenome_strand,$fragmentGenome_chr_len,$completeGenome_chr,$completeGenome_start,$completeGenome_end,$completeGenome_strand,$completeGenome_chr_len)=&read_maf(@alignment);
    $total_len += $fragmentGenome_end-$fragmentGenome_start+1;

    $completeGenome_len{$completeGenome_chr} = $completeGenome_chr_len;
    $fragmentGenome_len{$fragmentGenome_chr} = $fragmentGenome_chr_len;
    $link{$completeGenome_chr}{$completeGenome_start} = {completeGenome_end => $completeGenome_end, completeGenome_strand => $completeGenome_strand, fragmentGenome_chr => $fragmentGenome_chr, fragmentGenome_start => $fragmentGenome_start, fragmentGenome_end => $fragmentGenome_end, fragmentGenome_strand => $fragmentGenome_strand};
}
close I;

my %fragmentGenome_position;
my %fragmentGenome2completeGenome_len;
my %align_len;
foreach my $completeGenome_chr(sort keys %link){
    foreach my $completeGenome_start(sort {$a<=>$b} keys %{$link{$completeGenome_chr}}){
        my $completeGenome_end = $link{$completeGenome_chr}{$completeGenome_start}{completeGenome_end};
        my $completeGenome_strand = $link{$completeGenome_chr}{$completeGenome_start}{completeGenome_strand};

        my $fragmentGenome_chr = $link{$completeGenome_chr}{$completeGenome_start}{fragmentGenome_chr};
        my $fragmentGenome_start = $link{$completeGenome_chr}{$completeGenome_start}{fragmentGenome_start};
        my $fragmentGenome_end = $link{$completeGenome_chr}{$completeGenome_start}{fragmentGenome_end};
        my $fragmentGenome_strand = $link{$completeGenome_chr}{$completeGenome_start}{fragmentGenome_strand};

        my $fragmentGenome_chr_len = $fragmentGenome_len{$fragmentGenome_chr};

        push @{$fragmentGenome_position{$fragmentGenome_chr}{$completeGenome_chr}{pos}},$completeGenome_start;
        my $tag="$completeGenome_chr#$fragmentGenome_strand";
        # $fragmentGenome2completeGenome_len{$fragmentGenome_chr}{$completeGenome_chr}+=$fragmentGenome_end-$fragmentGenome_start+1;
        $fragmentGenome2completeGenome_len{$fragmentGenome_chr}{$tag}+=$fragmentGenome_end-$fragmentGenome_start+1;
        $align_len{$fragmentGenome_chr}+=$fragmentGenome_end-$fragmentGenome_start+1;
    }
}

open O,"> debug.txt";
print O "#FragmentChr\tFragmentChrLen\tAlignmentLen\tPercentAlignment\n";
foreach my $fragmentGenome_chr(sort keys %align_len){
    my $len = $align_len{$fragmentGenome_chr};
    my $fragmentGenome_chr_len=$fragmentGenome_len{$fragmentGenome_chr};
    my $percent = $len/$fragmentGenome_chr_len;
    print O "$fragmentGenome_chr\t$fragmentGenome_chr_len\t$len\t$percent\n";
}
close O;

my %result;
my %fragmentGenome_strand;
foreach my $fragmentGenome_chr(sort keys %fragmentGenome2completeGenome_len){
    foreach my $completeGenome_chr(sort {$fragmentGenome2completeGenome_len{$fragmentGenome_chr}{$b} <=> $fragmentGenome2completeGenome_len{$fragmentGenome_chr}{$a}} keys %{$fragmentGenome2completeGenome_len{$fragmentGenome_chr}}){
        my @tag_info=split("#",$completeGenome_chr);
        $completeGenome_chr=$tag_info[0];
        my $strand=$tag_info[1];
        my $chr=$completeGenome_chr;
        my @fragmentGenome_position=sort {$a<=>$b} @{$fragmentGenome_position{$fragmentGenome_chr}{$completeGenome_chr}{pos}};
        my $len=@fragmentGenome_position;
        my $mid=int(($len/2)+0.5);
        if($mid >= $len-1){
            $mid=$len-1;
        }
        elsif($mid < 0){
            $mid = 0;
        }
        my $pos=$fragmentGenome_position[$mid];
        $result{$chr}{$fragmentGenome_chr}=$pos;
        $fragmentGenome_strand{$fragmentGenome_chr}=$strand;
        last;
    }
}

open C,"> chromosome.txt";
print C "#CompleteChr\tFragmentChr\tPosInCompleteChr\tStrand\n";
foreach my $chr(sort keys %result){
    foreach my $fragmentGenome_chr(sort {$result{$chr}{$a}<=>$result{$chr}{$b}} keys %{$result{$chr}}){
        my $pos=$result{$chr}{$fragmentGenome_chr};
        my $chr_len=$fragmentGenome_len{$fragmentGenome_chr};
        # print C "chr - $fragmentGenome_chr $fragmentGenome_chr 1 $chr_len white\n";
        my $strand=$fragmentGenome_strand{$fragmentGenome_chr};
        print C "$chr\t$fragmentGenome_chr\t$pos\t$strand\n";
    }
}
close C;

sub read_maf{
    my @alignment=@_;
    # print "\n\n**************************START**************************\n";
    # print join "\n",@alignment;
    # print "\n***************************END***************************\n\n";
    my @speciesA=split /\s+/,$alignment[2];
    my @speciesB=split /\s+/,$alignment[1];
    my $chrA=$speciesA[1];
    my $chrB=$speciesB[1];

    my($startA,$lenA,$strandA,$chr_lenA)=($speciesA[2],$speciesA[3],$speciesA[4],$speciesA[5]);
    my $endA;
    if($strandA eq "+"){
        $startA = $startA + 1;
        $endA = $startA + $lenA - 1;
    }
    else{
        $startA = $chr_lenA - $startA;
        $endA = $startA - $lenA + 1;

        my $temp = $startA;
        $startA = $endA;
        $endA = $temp;
    }

    my($startB,$lenB,$strandB,$chr_lenB)=($speciesB[2],$speciesB[3],$speciesB[4],$speciesB[5]);
    my $endB;
    if($strandB eq "+"){
        $startB = $startB + 1;
        $endB = $startB + $lenB - 1;
    }
    else{
        $startB = $chr_lenB - $startB;
        $endB = $startB - $lenB + 1;

        my $temp = $startB;
        $startB = $endB;
        $endB = $temp;
    }
    return($chrA,$startA,$endA,$strandA,$chr_lenA,$chrB,$startB,$endB,$strandB,$chr_lenB);
}

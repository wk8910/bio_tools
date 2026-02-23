#!/usr/bin/perl -w
use strict;
use warnings;
my ($fastaFile)=@ARGV;
die("$0: <fastaFile>\n") unless($fastaFile);

my $control=0;
my %scaffolds;
my %contigs;
$/=">";
open(I,"< $fastaFile") or die "Cannot open $fastaFile!\n";
while(<I>){
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $id=shift @lines;
    my $seq=join "",@lines;
    $id=~/^(\S+)/;
    $id=$1;

    my $scaffoldLen=length($seq);
    my @seqWithoutN=split(/[Nn]+/,$seq);
    my $contigId=0;
    my $sizeWithoutN=0;
    foreach my $subSeq(@seqWithoutN){
        $contigId++;
        my $contigId4Record=$id."-".$contigId;
        my $subLen=length($subSeq);
        $contigs{$contigId4Record}{'len'}=$subLen;
        $contigs{$contigId4Record}{'n'}=0;
        $sizeWithoutN+=$subLen;
    }
    $scaffolds{$id}{'len'}=$scaffoldLen;
    $scaffolds{$id}{'n'}=$scaffolds{$id}{'len'}-$sizeWithoutN;
    $control++;
    print STDERR " [ $control ] scaffolds loaded...\r";
}
close I;
$/="\n";
print STDERR "\n";

print "\nscaffold:\n";
&statistics(\%scaffolds);
print "\ncontig:\n";
&statistics(\%contigs);

sub statistics{
    my $seqinfo=shift;
    my %seqs=%{$seqinfo};
    my @seqsArray=sort {$seqs{$b}{'len'} <=> $seqs{$a}{'len'}} keys %seqs;

    my $totallen=0;
    my $totalN=0;
    foreach my $id(@seqsArray){
        $totallen+=$seqs{$id}{'len'};
        $totalN+=$seqs{$id}{'n'};
    }

    print "total    :\t",scalar(@seqsArray),"(seqs), ",$totallen,"(bases), average length: ",$totallen/@seqsArray,"\n";
    print "longest  :\t", $seqsArray[0],"(name)\t",$seqs{$seqsArray[0]}{'len'},"(length)\n";
    print "shortest :\t",$seqsArray[$#seqsArray],"(name)\t", $seqs{$seqsArray[$#seqsArray]}{'len'},"(length)\n";
    my $len=0;
    my ($fn50,$fn90)=(1,1);
    my $num=0;
    foreach my $s(@seqsArray){
        $len+=$seqs{$s}{'len'};
        $num++;
        if($len/$totallen>0.5 && $fn50){
            print "n50    =\t",$seqs{$s}{'len'},"\t";
            print "number=$num\n";
            $fn50=0;
        }
        elsif($len/$totallen>0.9 && $fn90){
            print "n90    =\t",$seqs{$s}{'len'},"\t";
            print "number=$num\n";
            $fn90=0;
            last;
        }
    }
    print "totalN =\t$totalN\t";
    my $percent=$totalN/$totallen;
    print "N percent : $percent\n";
}

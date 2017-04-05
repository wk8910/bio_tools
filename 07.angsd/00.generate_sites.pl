#! /usr/bin/perl -w
use strict;
use warnings;

my $dict="/home/share/user/user101/projects/yangshu/11.ref/ptr.dict";
my $repeat="/home/share/user/user101/projects/yangshu/11.ref/Ptrichocarpa/annotation/Ptrichocarpa_210_v3.0.repeatmasked_assembly_v3.0.gff3.gz";
my $out=$0.".txt";
my $output_len=0;

my %len;

my @chr;
open(I,"< $dict");
while(<I>){
    chomp;
    next unless(/SN:(\S+)\s+LN:(\d+)/);
    my ($chr,$len)=($1,$2);
    $len{$chr}=$len;
    push @chr,$chr;
}
close I;


my %repeat;
my $seat=1;
open(I,"zcat $repeat |");
while(<I>){
    next if(/^#/);
    chomp;
    next if(/^\s*$/);
    my @a=split(/\s+/);
    my ($chr,$start,$end)=($a[0],$a[3],$a[4]);
    $repeat{$chr}{$seat}{start}=$start;
    $repeat{$chr}{$seat}{end}=$end;
    $seat++;
}
close I;

open(O,"> $out");
foreach my $chr(@chr){
    my $len=$len{$chr};
    my $pre_end=0;
    if(!exists $repeat{$chr}){
	&output($chr,1,$len);
    }
    else{
	foreach my $seat(sort { $repeat{$chr}{$a}{start} <=> $repeat{$chr}{$b}{end} } keys %{$repeat{$chr}}){
	    my $start=$repeat{$chr}{$seat}{start};
	    my $end=$repeat{$chr}{$seat}{end};
	    my $x=$start-1; # end of this region (region without repeat)
	    my $y=$pre_end+1; # start of this region
	    if($start-$pre_end>1){
		&output($chr,$y,$x);
	    }
	    $pre_end=$end;
	}
	if($pre_end<$len){
	    &output($chr,$pre_end+1,$len);
	}
    }
}
close O;
print "$output_len\n";


sub output{
    my ($chr,$start,$end)=@_;
    if($start-$end==1){
	return();
    }
    if($start>=$end){
	# print STDERR "What!\n$chr\t$start\t$end";
	# print "$chr\t$start\t$end\n";
	return();
    }
    $output_len+=$end-$start+1;
    print O "$chr\t$start\t$end\n";
}

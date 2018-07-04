#! /usr/bin/env perl
use strict;
use warnings;

my $maf="ss2ds.single.maf";
my $length_of_scaffold_plotted = 0;

my %link;
my %cattle_len;
my %wisent_len;

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
    my ($wisent_chr,$wisent_start,$wisent_end,$wisent_strand,$wisent_chr_len,$cattle_chr,$cattle_start,$cattle_end,$cattle_strand,$cattle_chr_len)=&read_maf(@alignment);
    next if($wisent_chr_len < $length_of_scaffold_plotted);
    $total_len += $wisent_end-$wisent_start+1;
    $link_num++;

    $cattle_len{$cattle_chr} = $cattle_chr_len;
    $wisent_len{$wisent_chr} = $wisent_chr_len;
    # $link{$cattle_chr}{$cattle_start} = {cattle_end => $cattle_end, cattle_strand => $cattle_strand, wisent_chr => $wisent_chr, wisent_start => $wisent_start, wisent_end => $wisent_end, wisent_strand => $wisent_strand};
    $link{$wisent_chr}{$wisent_start} = {cattle_chr => $cattle_chr, cattle_start => $cattle_start, cattle_end => $cattle_end, cattle_strand => $cattle_strand, wisent_end => $wisent_end, wisent_strand => $wisent_strand};
    # last if($control++>1000);
}
close I;

my @simple_report; # breakpoint总的简单统计
open S,"> $0.breakpoint_info";
print S "chr\tstart\tend\ttype\n";
open L,"> $0.record";
open O,"> $0.sta";
print O "chr\tlen\tinter_chromosome\tinversion\ttranslocation\tinsertion\tdeletion\n";
foreach my $wisent_chr(sort keys %link){
    my $link_num = keys %{$link{$wisent_chr}};
    # next if($link_num<5);
    print L "\n\n**************************START**************************\n";
    my $wisent_chr_len = $wisent_len{$wisent_chr};
    print L "$wisent_chr\t$wisent_chr_len\n";

    my %sv_type;

    foreach my $wisent_start(sort {$a<=>$b} keys %{$link{$wisent_chr}}){
	my $cattle_chr = $link{$wisent_chr}{$wisent_start}{cattle_chr};
	my $cattle_start = $link{$wisent_chr}{$wisent_start}{cattle_start};
	my $cattle_end = $link{$wisent_chr}{$wisent_start}{cattle_end};
	my $cattle_strand = $link{$wisent_chr}{$wisent_start}{cattle_strand};

    	my $wisent_end = $link{$wisent_chr}{$wisent_start}{wisent_end};
    	my $wisent_strand = $link{$wisent_chr}{$wisent_start}{wisent_strand};

	print L "$wisent_start\t$wisent_end\t$wisent_strand\t<->\t$cattle_chr\t$cattle_start\t$cattle_end\t$cattle_strand\n";
    }
    print L "\n";

    my ($cattle_chr_pre,$wisent_chr_pre,$cattle_start_pre,$cattle_end_pre,$cattle_strand_pre,$wisent_start_pre,$wisent_end_pre,$wisent_strand_pre);
    foreach my $wisent_start(sort {$a<=>$b} keys %{$link{$wisent_chr}}){
	my $cattle_chr = $link{$wisent_chr}{$wisent_start}{cattle_chr};
	my $cattle_start = $link{$wisent_chr}{$wisent_start}{cattle_start};
	my $cattle_end = $link{$wisent_chr}{$wisent_start}{cattle_end};
	my $cattle_strand = $link{$wisent_chr}{$wisent_start}{cattle_strand};

    	my $wisent_end = $link{$wisent_chr}{$wisent_start}{wisent_end};
    	my $wisent_strand = $link{$wisent_chr}{$wisent_start}{wisent_strand};

	if($wisent_strand eq "-"){
	    if($cattle_strand eq "+"){
		$cattle_strand = "-";
	    }
	    else{
		$cattle_strand = "+";
	    }
	    $wisent_strand = "+";
	}

    	my $wisent_chr_len = $wisent_len{$wisent_chr};

	my $flag = 1; #记录此alignment与上一个alignment是否处于同一个方向
	my $wisent_dis = 0;
	if($cattle_chr_pre){
	    $wisent_dis = $wisent_start - $wisent_end_pre;
	}
	my $cattle_dis = 0;

	if($cattle_chr_pre){
	    $flag = 0;
	    if($cattle_strand_pre eq $cattle_strand && $cattle_strand eq "+"){
		if($cattle_start > $cattle_end_pre){
		    $flag = 1;
		    $cattle_dis = $cattle_start - $cattle_end_pre;
		}
	    }
	    elsif($cattle_strand_pre eq $cattle_strand && $cattle_strand eq "-"){
		if($cattle_end < $cattle_start_pre){
		    $flag = 1;
		    $cattle_dis = $cattle_start_pre - $cattle_end;
		}
	    }
	    elsif($cattle_chr eq $cattle_chr_pre){
		$cattle_dis = $cattle_start - $cattle_end_pre;
		if($cattle_dis < 0){
		    $cattle_dis = $cattle_start_pre - $cattle_end;
		}
	    }
	}

	my $flag_dis = 0; # 这个是判断两个alignment在两个物种基因组上的距离是否显著的差异，是否存在插入缺失
	if($wisent_dis > 0 && $cattle_dis > 0){
	    my $diff = $cattle_dis - $wisent_dis;
	    my $fold = $cattle_dis/$wisent_dis;
	    if($fold < 1){
		$fold = $wisent_dis/$cattle_dis;
	    }
	    if(abs($diff) >= 1000 && $fold >= 2){
		if($diff > 0){
		    $flag_dis = -1;
		}
		else{
		    $flag_dis = 1;
		}
	    }
	}
	
	if(!$cattle_chr_pre){
	    $cattle_chr_pre=$cattle_chr;
	    $cattle_start_pre=$cattle_start;
	    $cattle_end_pre=$cattle_end;
	    $cattle_strand_pre=$cattle_strand;

	    $wisent_chr_pre=$wisent_chr;
	    $wisent_start_pre=$wisent_start;
	    $wisent_end_pre=$wisent_end;
	    $wisent_strand_pre=$wisent_strand;
	}
	elsif($cattle_chr ne $cattle_chr_pre || $cattle_strand_pre ne $cattle_strand || $flag == 0 || $flag_dis != 0){
	    my $sv_type = "NA";
	    if($cattle_chr ne $cattle_chr_pre){
		$sv_type = "inter_chromosome";
	    }
	    elsif($cattle_strand_pre ne $cattle_strand){
		if($flag_dis == 0){
		    $sv_type = "inversion";
		}
		else{
		    $sv_type = "translocation";
		}
	    }
	    elsif($flag == 0){
		$sv_type = "translocation";
	    }
	    elsif($flag_dis == 1){
		$sv_type = "insertion";
	    }
	    elsif($flag_dis == -1){
		$sv_type = "deletion";
	    }

	    $sv_type{$sv_type}++;

	    # print "$cattle_chr ne $cattle_chr_pre || $wisent_chr ne $wisent_chr_pre || $wisent_strand_pre ne $wisent_strand || $cattle_strand_pre ne $cattle_strand\n";
	    print L "$wisent_start_pre\t$wisent_end_pre\t$wisent_strand_pre\t<=>\t$cattle_chr_pre\t$cattle_start_pre\t$cattle_end_pre\t$cattle_strand_pre\tsv:$sv_type\n";
	    print S "$wisent_chr\t$wisent_end_pre\t$wisent_start\t$sv_type\n";
	    $cattle_chr_pre=$cattle_chr;
	    $cattle_start_pre=$cattle_start;
	    $cattle_end_pre=$cattle_end;
	    $cattle_strand_pre=$cattle_strand;

	    $wisent_chr_pre=$wisent_chr;
	    $wisent_start_pre=$wisent_start;
	    $wisent_end_pre=$wisent_end;
	    $wisent_strand_pre=$wisent_strand;
	}
	else{
	    my @cattle_pos=sort {$a<=>$b} ($cattle_start,$cattle_start_pre,$cattle_end,$cattle_end_pre);
	    $cattle_start_pre=$cattle_pos[0];
	    $cattle_end_pre=$cattle_pos[-1];

	    my @wisent_pos=sort {$a<=>$b} ($wisent_start,$wisent_start_pre,$wisent_end,$wisent_end_pre);
	    $wisent_start_pre=$wisent_pos[0];
	    $wisent_end_pre=$wisent_pos[-1];
	}
    }
    print L "$wisent_start_pre\t$wisent_end_pre\t$wisent_strand_pre\t<=>\t$cattle_chr_pre\t$cattle_start_pre\t$cattle_end_pre\t$cattle_strand_pre\n";
    print L "\n***************************END***************************\n\n";
    my ($type1,$type2,$type3,$type4,$type5)=(0,0,0,0,0);
    if(exists $sv_type{inter_chromosome}){
	$type1=$sv_type{inter_chromosome};
    }
    if(exists $sv_type{inversion}){
	$type2=$sv_type{inversion};
    }
    if(exists $sv_type{translocation}){
	$type3=$sv_type{translocation};
    }
    if(exists $sv_type{insertion}){
	$type4=$sv_type{insertion};
    }
    if(exists $sv_type{deletion}){
	$type5=$sv_type{deletion};
    }
    print O "$wisent_chr\t$wisent_chr_len\t$type1\t$type2\t$type3\t$type4\t$type5\n";
    $simple_report[0]+=$wisent_chr_len;
    $simple_report[1]+=$type1;
    $simple_report[2]+=$type2;
    $simple_report[3]+=$type3;
    $simple_report[4]+=$type4;
    $simple_report[5]+=$type5;
}
close L;
close O;
close S;

open O,"> $0.simple_report";
my @head=("len","inter_chromosome","inversion","translocation","insertion","deletion");
print O "$head[0]\t$simple_report[0]\n";
for(my $i=1;$i<@head;$i++){
    my $percent=$simple_report[$i]/$simple_report[0];
    my $value=$percent*1e6;
    print O "$head[$i]\t$percent\t$value\n";
}
close O;

sub read_maf{
    my @alignment=@_;
    # print "\n\n**************************START**************************\n";
    # print join "\n",@alignment;
    # print "\n***************************END***************************\n\n";
    my @speciesA=split /\s+/,$alignment[1];
    my @speciesB=split /\s+/,$alignment[2];
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


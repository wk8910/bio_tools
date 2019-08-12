#! /usr/bin/env perl
use strict;
use warnings;

my ($fastq_lst,$out_prefix)=@ARGV;
my $min_length=500;
my $min_qual=7;

if(@ARGV < 2){
    die "Usage: $0 <fastq file list> <output prefix>\n";
}
my $out="$out_prefix.fa.gz";
my $sta="$out_prefix.sta";

my @len;
my ($num,$sum)=(0,0);
my ($raw_num,$raw_sum)=(0,0);
open L,"< $fastq_lst";
open O1,"| gzip - > $out" or die "Cannot create $out.fa.gz\n";
open O2,"> $sta" or die "Cannot create $sta\n";
print O2 "# id\traw_num\traw_base\tclean_num\tclean_base\tmean_len\tN50\tN50_number\tmedium_len\tmax_len\n";
while(<L>){
    chomp;
    my $fastq=$_;
    if($fastq=~/.gz$/){
        open I,"zcat $fastq |";
    }
    else{
        open I,"< $fastq";
    }
    my $id=$fastq;

    print O2 "$id\t";

    while(my $l1=<I>){
        my $l2=<I>;
        my $l3=<I>;
        my $l4=<I>;

        chomp $l1;
        chomp $l2;
        chomp $l3;
        chomp $l4;
 
        if($l1!~/^\@/ || $l3!~/^\+/){
            my $line_num=$num*2;
            die "line $line_num error: $l1\n$l2\n";
        }
        my $len=length($l2);
        next if($len<$min_length);
        
        $raw_num++;
        $raw_sum+=$len;
        
        my $qual=&mean_qual($l4);
        
        next if($qual<$min_qual);
        $l1=~s/\@/>/;
        print O1 "$l1\n$l2\n";
        
        push @len,$len;
        $num++;
        $sum+=$len;
    }
    close I;
}
close O1;
print O2 "$raw_num\t$raw_sum\t";
&statistics(\@len,$num,$sum);
close O2;

sub mean_qual{
    my $line=shift;
    my @qual=split(//,$line);
    my $total=0;
    my $len=scalar(@qual);
    foreach my $base(@qual){
        $total+=ord($base)-33;
    }
    my $mean_qual=$total/$len;
}

sub statistics{
    my ($array,$num,$sum)=@_;
    my @a=@{$array};

    my @sort_a=sort {$b<=>$a} @a;
    my $mean_len=$sum/$num;
    my $max_len=$sort_a[0];
    my $medium_len=$sort_a[int($num/2+0.5)];
    my $temp=0;
    my $n50=0;
    my $n50_num=0;
    foreach my $len(@sort_a){
        $temp+=$len;
        $n50_num++;
        if($temp/$sum>0.5){
            $n50=$len;
            last;
        }
    }
    print O2 "$num\t$sum\t$mean_len\t$n50\t$n50_num\t$medium_len\t$max_len\n";
}


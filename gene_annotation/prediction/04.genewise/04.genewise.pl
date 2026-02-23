#! /usr/bin/env perl
use strict;
use warnings;

my $psl="03.filter.pl.out";
my $all_query="all.query";
my $prefix="sterlet";
my $genome="/data2/home/wangkun/03.sterlet/00.genome/sterlet.fa";

my $genewise="~/software/genewise/wise2.4.1/src/bin/genewise";

my $log="corresponding.list";
my $scaffold="scaffolds";
my $outdir="prediction";
my $now=$ENV{'PWD'};;
`mkdir $outdir` if(!-e $outdir);

my %hash;
open I,"< $psl";
my $num=0;
open O,"> $0.sh";
open L,"> $log";
while (<I>) {
    chomp;
    next if(/^#/);
    $num++;
    my $name="0" x (6-length($num));
    $name=$prefix.$name.$num;
    my @a=split(/\s+/);
    my ($query,$target,$strand,$start,$end,$tsize)=($a[9],$a[13],$a[8],$a[15],$a[16],$a[14]);
    $start=$start-5000;
    $start=1 if($start<1);
    $end=$end+5000;
    $end=$tsize if($end>$tsize);
    if($strand eq "+"){
        $strand = "for";
    }
    else {
        $strand = "rev";
    }
    `mkdir $outdir/$name` if(!-e "$outdir/$name");
    # `ln -s $now/$scaffold/$target.fa $now/$outdir/$name/ref.fa` if(!-e "$now/$outdir/$name/ref.fa");
    `samtools faidx $genome $target:$start-$end > $now/$outdir/$name/ref.fa` if(!-e "$now/$outdir/$name/ref.fa");
    print O "cd $now/$outdir/$name/; $genewise query.fa -nosplice_gtag -t$strand $now/$outdir/$name/ref.fa -pretty -pseudo -gff -cdna -trans > $name.genewise ; perl $now/sub.convert_genewise.pl $name.genewise ; cd -\n";
    $hash{$query}{$name}=1;
    print L "$query\t$name\n";
    # last if($num>10);
}
close I;
close O;
close L;

$/=">";
open(I,"< $all_query");
while (<I>) {
    chomp;
    my @lines=split("\n",$_);
    next if(@lines==0);
    my $query=shift @lines;# the name of fasta is $id
    $query=~/^(\S+)/;
    $query=$1;
    my $seq=join "",@lines;# the sequence of fasta is $seq
    next unless(exists $hash{$query});
    foreach my $name(keys %{$hash{$query}}){
        next if(-e "$outdir/$name/query.fa");
        open O,"> $outdir/$name/query.fa" || die "cannot create $outdir/$name/query.fa\n";
        print O ">$query\n$seq\n";
        close O;
    }
}
close I;
$/="\n";


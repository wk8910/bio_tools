#! /usr/bin/env perl
use strict;
use warnings;

my ($vcf,$outdir)=@ARGV;
if(@ARGV<2){
    die "Usage: $0 <beagle phased vcf file> <output directory>\n(i) beagle phased vcf file = filename of BEAGLE v4 or more (vcf) phased file.\n(ii) output directory = filename prefix for chromopainter input file(s). The suffixes \".phase\", \".recombfile\" and \".ids\" are added.\n(iii) it should be noted that file with chromosome was supported.\nThe output, by default, is in CHROMOPAINTER v2 input format. NOTE THAT ONLY BIALLELIC SNPS ARE RETAINED, i.e. we omit triallelic and non-polymorphic sites.\n";
}
die "$vcf did not existed" if(!-e $vcf);

`mkdir $outdir` if(!-e $outdir);

if($vcf=~/\.gz$/){
    open I,"zcat $vcf |";
}
else{
    open I,"< $vcf";
}
$vcf=~/([^\/]+).vcf/;
my $filename=$1;

my @ind;
while (<I>) {
    chomp;
    if(/^##/){
        next;
    }
    if(/^#/){
        my @a=split(/\s+/);
        open O,"> $outdir/$filename.idx";
        for(my $i=9;$i<@a;$i++){
            push @ind,$a[$i];
            print O "$a[$i] \n";
        }
        close O;
        last;
    }
}

my %geno;
my %pos;
my %output;
my $previous_chr="NA";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    next if(@a==0);
    my ($chr,$pos)=($a[0],$a[1]);
    if($previous_chr ne $chr && exists $pos{$previous_chr}){
        &print_chr($previous_chr);
    }
    next unless($chr=~/chr/);
    $previous_chr=$chr;
    splice(@a,0,9);
    my $len1=@a;
    my $len2=@ind;
    # die "$len1\t$len2\n";
    my $test=join "\t",@a;
    next if($test=~/2|3|4/);
    for(my $i=0;$i<@a;$i++){
        my $ind=$ind[$i];
        if($a[$i]=~/^(\d)\|(\d)/){
            push @{$geno{$chr}{$ind}{1}},$1;
            push @{$geno{$chr}{$ind}{2}},$2;
        }
        else {
            die "$vcf is not the output of beagle v4 or more!\nThis line should be like \"0|1\"\n";
        }
    }
    push @{$pos{$chr}},$pos ;

}
close I;
&print_chr($previous_chr);

sub print_chr{
    my $previous_chr=shift;
    my @pos=@{$pos{$previous_chr}};
    my $ind_number=@ind;
    my $pos_number=@pos;
    my $pos_head=join " ",@pos;
    $pos_head="P ".$pos_head;
    open O,"> $outdir/$filename.$previous_chr.phase";
    $ind_number*=2;
    print O "$ind_number\n$pos_number\n$pos_head\n";
    foreach my $ind(@ind){
        my @geno1=@{$geno{$previous_chr}{$ind}{1}};
        my $geno_line1=join "",@geno1;
        print O "$geno_line1\n";
        my @geno2=@{$geno{$previous_chr}{$ind}{2}};
        my $geno_line2=join "",@geno2;
        print O "$geno_line2\n";
    }
    close O;
    open O,"> $outdir/$filename.$previous_chr.recombfile";
    print O "start.pos recom.rate.perbp\n";
    my $last=pop(@pos);
    foreach my $pos(@pos){
        print O "$pos 0.00000010000000000000\n";
    }
    print O "$last 0.00000000000000000000\n";
    close O;
    delete $geno{$previous_chr};
    delete $pos{$previous_chr};
}

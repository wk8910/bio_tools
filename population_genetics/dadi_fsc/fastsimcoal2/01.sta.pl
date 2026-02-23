#! /usr/bin/env perl
use strict;
use warnings;

my @folder=<./*>;
# my @folder=<topology*/*>;

my %result;
my $min=-1;
foreach my $folder(@folder){
    next if(!-d "$folder");
    next if(!-e "$folder/replicates/run1/model.bestlhoods");
    open(I,"< $folder/model.est");
    my $num=0;
    my $light=-1;
    while (<I>) {
        chomp;
        next if(/^\//);
        next if(/^$/);
        last if(/^\[R/);
        $num++ if($light>0);
        $light=$light*-1 if(/^\[PARAMETERS\]/);
    }
    close I;

    my @bestlhoods=<$folder/replicates/run*/model.bestlhoods>;
    my %hash;
    my $i=1;
    foreach my $bestlhoods(@bestlhoods){
        $i++;
        open(I,"< $bestlhoods");
        <I>;
        my $line=<I>;
        chomp $line;
        my @a=split(/\s+/,$line);
        my $lhoods=$a[-2];
        $hash{$i}{lhoods}=$lhoods;
        $hash{$i}{content}=$line;
        $hash{$i}{file}=$bestlhoods;
        close I;
    }
    my @a=sort {$hash{$b}{lhoods} <=> $hash{$a}{lhoods}} keys %hash;
    my $select=$a[0];
    #print $folder,"\t",$hash{$a[0]}{lhoods},"\t",$num,"\n";
    $result{$folder}{lhoods}=$hash{$a[0]}{lhoods};
    $result{$folder}{num}=$num;
    $result{$folder}{file}=$hash{$a[0]}{file};
    my $aic=2*$num-2*( $hash{$a[0]}{lhoods} * log(10) );
    $result{$folder}{AIC}=$aic;
    if($min<0){
        $min=$aic;
    }
    elsif($min>$aic) {
        $min=$aic;
    }
}

print STDERR "folder\tlikelihood\tNo_of_parameters\tAIC\tdelta\tW\tfile_location\n";
foreach my $folder(sort { $result{$a}{AIC} <=> $result{$b}{AIC} } keys %result){
    my $lhoods=$result{$folder}{lhoods};
    my $d=$result{$folder}{num};
    my $aic=$result{$folder}{AIC};
    my $delta=$aic-$min;
    my $wi=exp($delta*(-0.5));

    my $file=$result{$folder}{file};
    print "$folder\t$lhoods\t$d\t$aic\t$delta\t$wi\t$file\n";
}

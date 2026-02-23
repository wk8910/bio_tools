#! /usr/bin/env perl
use strict;
use warnings;

my $file="02.calculate_distance.pl.sta";
my $out="$0.svg";
my $min=1000;

my %color=("cattle_wisent" => "#d7191c", "cattle_bison" => "#4daf4a", "wisent_bison" => "#2c7bb6");

my $height=150;
my $width=400;

my $max=0.03; # max value of distance

my %hash;
my %length;
open I,"< $file";
my $chr="NA";
my $head=<I>;
chomp $head;
my @head=split(/\s+/,$head);

while(<I>){
    chomp;
    my @a=split(/\s+/);
    my ($chr,$window,$informative_site)=($a[0],$a[1],$a[2]);
    next unless($chr=~/CHR/);
    next if($informative_site < $min);
    next if($chr=~"Y");
    $chr=~s/CHR//;
    if($chr eq "X"){
	$chr="99";
    }
    if($chr eq "Y"){
	$chr="100";
    }
    for(my $i=3;$i<@a;$i++){
	my $id=$head[$i];
	my $dis=$a[$i]/$informative_site;
	# if($dis>=$max){
	#     $max=$dis;
	# }
	$hash{$chr}{$id}{$window}=$dis;
	$length{$chr}{$window}=1;
    }
}
close I;

my %len;
my $sum;
foreach my $chr(sort {$a<=>$b} keys %length){
    foreach my $window(sort {$b<=>$a} keys %{$length{$chr}}){
	$len{$chr}=$window;
	$sum+=$window;
	last;
    }
}

my $ratio=$width/$sum;
my $step=10;
open O,"> $out";
print O '<?xml version="1.0" encoding="utf-8"?>
<!-- Generator: Adobe Illustrator 16.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
 width="900px" height="200px" viewBox="0 0 900 200" enable-background="new 0 0 900 200" xml:space="preserve">
';

my $color_light=1;
foreach my $chr(sort {$a<=>$b} keys %hash){
    print "$chr\n";
    my $len=$len{$chr};
    my $w=$len*$ratio;
    my $color="#E6E7E8";
    if($color_light==-1){
	$color="#FFFFFF";
    }
    print O '<rect x="'.$step.'" y="10" fill="'.$color.'" width="'.$w.'" height="'.$height.'"/>
';
    foreach my $id(sort keys %{$hash{$chr}}){
	my $combination_color="#231F20";
	if(exists $color{$id}){
	    $combination_color=$color{$id};
	}
	my $line='<polyline fill="none" stroke="'.$combination_color.'" stroke-width="0.25" stroke-miterlimit="10" points="';
	foreach my $window(sort {$a<=>$b} keys %{$hash{$chr}{$id}}){
	    my $value=$hash{$chr}{$id}{$window};
	    if($value>$max){
		$value=$max;
	    }
	    my $y=($height+10)-($height*($value/$max));
	    my $x=$step+($window*$ratio);
	    my $position=$x.",".$y." ";
	    $line.=$position;
	}
	$line.='"/>
';
	print O "$line\n";
    }
    $step+=$w;
    $color_light*=-1;
}
print O '</svg>
';
close O;

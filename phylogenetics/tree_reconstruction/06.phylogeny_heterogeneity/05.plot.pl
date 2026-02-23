#! /usr/bin/env perl
use strict;
use warnings;

my $file="04.classify.pl.txt";
my $out="$0.svg";

# my %color=("class1" => "#e31a1c", "class2" => "#1f78b4", "class3" => "#fb9a99", "class4" => "#a6cee3", "class5" => "#33a02c", "class6" => "#b2df8a", "class7" => "#ff7f00", "class8" => "#fdbf6f", "class9" => "#6a3d9a", "class10" => "#cab2d6");
my %color=("class1" => "#e31a1c", "class2" => "#1f78b4", "class3" => "#fb9a99", "class4" => "#a6cee3", "class5" => "#33a02c");

my $height=150;
my $width=600;

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
    my ($chr,$window,$type)=($a[0],$a[1],$a[2]);
    next unless($chr=~/Chr/);
    $chr=~s/Chr//;
    $hash{$chr}{$window}=$type;
    $length{$chr}{$window}=1;
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
    print O '<rect x="'.$step.'" y="10" fill="none" stroke="#000000" width="'.$w.'" height="'.$height.'"/>
';
    foreach my $window(sort {$a<=>$b} keys %{$hash{$chr}}){
        my $type=$hash{$chr}{$window};
        my $color="#FFFFFF";
        if(exists $color{$type}){
            $color=$color{$type}
        }
        my $y1=10;
        my $y2=$y1+$height;
        my $x=$step+($window*$ratio);
        print O '<line fill="none" stroke="'.$color.'" stroke-width="0.25" stroke-miterlimit="10" x1="'.$x.'" y1="'.$y1.'" x2="'.$x.'" y2="'.$y2.'"/>';
    }
    $step+=$w;
    $step+=5;
    $color_light*=-1;
}
print O '</svg>
';
close O;

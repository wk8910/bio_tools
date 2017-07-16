#! /usr/bin/env perl
use strict;
use warnings;

my $input="Localtree.out";
my $min_len=100;
my $output="$0.svg";
my $res=0.05;
# my %color=("cactus0" => "#a6cee3", "cactus1" => "#1f78b4", "cactus2" => "#b2df8a", "cactus3" => "#33a02c", "cactus4" => "#fb9a99",
#           "cactus5" => "#e31a1c", "cactus6" => "#fdbf6f", "cactus7" => "#ff7f00", "cactus8" => "#cab2d6", "cactus9" => "#6a3d9a", "cactus10" => "#D1D3D4");
my %color=("cactus0" => "#a6cee3", "cactus1" => "#D1D3D4", "cactus2" => "#4daf4a", "cactus3" => "#D1D3D4", "cactus4" => "#D1D3D4",
          "cactus5" => "#D1D3D4", "cactus6" => "#D1D3D4", "cactus7" => "#D1D3D4", "cactus8" => "#D1D3D4", "cactus9" => "#e31a1c", "cactus10" => "#D1D3D4");

my %sta;
my %chromosome;
my @chromosome;
my %record;
my $sum;
open(I,"< $input");
my $chr_pre="NA";
while (<I>) {
    chomp;
    next unless(/^(cactus\d+)\s*(\w+):\s+(\d+)\s+\-\s+(\d+)\s+length: (\d+)/);
    my ($tree,$chr,$start,$end,$len)=($1,$2,$3,$4,$5);
    next if($chr=~/scaffold/);
    if($chr ne $chr_pre){
        push @chromosome, $chr;
    }
    $chr_pre=$chr;
    $chromosome{$chr}=$end if(!exists $chromosome{$chr} or $chromosome{$chr} < $end);
    $sta{$tree}+=$len;
    next if($len<$min_len);
    $sum+=$len;
}
close I;

my $longest=-1;
foreach my $chr(@chromosome){
    if($chromosome{$chr} > $longest){
        $longest = $chromosome{$chr};
    }
}

my $wind_size=$longest/(450/$res);
my %window_sta;
open I,"< $input";
while(<I>){
    chomp;
    next unless(/^(cactus\d+)\s*(\w+):\s+(\d+)\s+\-\s+(\d+)\s+length: (\d+)/);
    my ($tree,$chr,$start,$end,$len)=($1,$2,$3,$4,$5);
    next if($chr=~/scaffold/);
    next if($len<$min_len);

    my $start_index=int($start/$wind_size);
    my $end_index=int($start/$wind_size);
    for(my $i=$start_index;$i<=$end_index;$i++){
        my $tmp_start=$i*$wind_size;
        if($tmp_start < $start){
            $tmp_start=$start;
        }
        my $tmp_end=($i+1)*$wind_size;
        if($tmp_end > $end){
            $tmp_end = $end;
        }
        my $tmp_len=$tmp_end-$tmp_start;
        $window_sta{$chr}{$i}{$tree}+=$tmp_len;
    }
}
close I;

open O,"> $output";
print O '<?xml version="1.0" encoding="utf-8"?>
<!-- Generator: Adobe Illustrator 16.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<svg version="1.2" baseProfile="tiny" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
 x="0px" y="0px" width="612px" height="792px" viewBox="0 0 612 792" xml:space="preserve">'."\n";
my $x=40;
my $y_step=10;
foreach my $chr(@chromosome){
    my $len=$chromosome{$chr};
    my $width=int(4500 * $len/$longest)/10;
    my $height=20;
    my $font_pos=$y_step+15;
    print O '<text transform="matrix(1 0 0 1 5 '.$font_pos.')" font-family="\'Arial\'" font-size="12">'.$chr.'</text>'."\n";
    print O '<g>'."\n";
    print O '    <rect x="'.$x.'" y="'.$y_step.'" fill="none" stroke="#000000" stroke-width="0.25" stroke-miterlimit="10" width="'.$width.'" height="'.$height.'"/>'."\n";
    foreach my $i(sort keys %{$window_sta{$chr}}){
        my $color="NA";
        foreach my $tree(sort { $window_sta{$chr}{$i}{$b} <=> $window_sta{$chr}{$i}{$a} } keys %{$window_sta{$chr}{$i}}){
            $color=$tree;
            last;
        }
        next if($color eq "NA");
        $color=$color{$color};
        my $y2=$y_step+$height;
        my $x_step=$x+$i*$res+$res/2;
        print O '    <line fill="none" stroke="'.$color.'" stroke-width="'.$res.'" stroke-miterlimit="10" x1="'.$x_step.'" y1="'.$y_step.'" x2="'.$x_step.'" y2="'.$y2.'"/>'."\n";
    }
    print O '</g>'."\n";
    $y_step+=$height+10;
}
print O '</svg>'."\n";
close O;

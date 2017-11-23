#! /usr/bin/env perl
use strict;
use warnings;
my %sta;
<>;
while(<>){
    chomp;
    my @a=split(/\s+/);
    if($a[0]=~/^\d+$/){
        my $pre=0 x (2-length($a[0]));
        $a[0]="Chr".$pre.$a[0];
    }
    my $line=join "\t",@a;
    $sta{$a[0]}{$a[1]}=$line;
}

foreach my $chr(sort keys %sta){
    foreach my $window(sort {$a<=>$b} keys %{$sta{$chr}}){
	print "$sta{$chr}{$window}\n";
    }
}

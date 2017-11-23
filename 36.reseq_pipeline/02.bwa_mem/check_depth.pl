my ($cover,$totalLength)=(0,0);
my %hash;
while(<>){
    chomp;
    my @a=split(/\s+/);
    $totalLength+=$a[1];
    $hash{$a[0]}=$a[1];
}

foreach my $depth(sort {$a<=>$b} keys %hash){
    my $num=0;
    foreach my $i(sort {$a<=>$b} keys %hash){
	next if($i<$depth);
	$num+=$hash{$i};
    }
    my $percent=$num/$totalLength;
    print "$depth\t$percent\t$totalLength\n";
}

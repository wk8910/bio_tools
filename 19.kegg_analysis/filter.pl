my $head=<>;
print "$head";
while (<>) {
    chomp;
    my @a=split(/\t/);
    next if($a[3]>0.05 || $a[-1]<0);
    next if($a[2]=~/NaN/);
    print "$_\n";
}

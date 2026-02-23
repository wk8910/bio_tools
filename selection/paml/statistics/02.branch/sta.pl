while(<>){
    chomp;
    my @a=split(/\s+/);
    next unless($a[12] <= 0.05);
    print "$_\n";
}

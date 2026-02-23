while(<>){
    chomp;
    my @a=split(/\s+/);
    next unless($a[7] <= 0.05);
    print "$_\n";
}

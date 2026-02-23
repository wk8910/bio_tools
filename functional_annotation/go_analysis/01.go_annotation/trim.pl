while(<>){
    chomp;
    my @a=split(/\s+/);
    $a[0]=~s/\.(\d*)$//;
    my $line=join "\t",@a;
    print "$line\n";
}

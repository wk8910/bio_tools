`touch outfile` if(!-e "outfile");
`touch outtree` if(!-e "outtree");

my $phylip="/home/share/software/phylip/phylip-3.695/exe/neighbor";
my @tree=<cactus*>;

foreach my $tree(@tree){
    next if($tree=~/\./);
    open(O,"> $tree.config");
    print O "$tree\nF\n$tree.out\nY\nF\n$tree.phb\n";
    close O;
    my $cmd="$phylip < $tree.config";
    `rm $tree.out` if(-e "$tree.out");
    `rm $tree.phb` if(-e "$tree.phb");
    system($cmd);
}

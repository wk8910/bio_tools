my @ld=<*.ld.gz>;

open O,"> $0.sh";
foreach my $ld(@ld){
    print O "perl calculate_decay.pl $ld\n";
}
close O;

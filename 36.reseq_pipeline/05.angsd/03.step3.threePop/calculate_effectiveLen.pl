my $line=<>;
chomp $line;
my @a=split(/\s+/,$line);
my $len=@a;
print "$len\n";
my $sum;
foreach my $i(@a){
    $sum+=$i;
}
print "$sum\n";

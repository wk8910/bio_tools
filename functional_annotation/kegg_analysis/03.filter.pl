my @kegg=<result*.txt>;
`mkdir kegg` if(!-e "kegg");
foreach my $kegg(@kegg){
    print "perl filter.pl $kegg > kegg/$kegg\n";
}

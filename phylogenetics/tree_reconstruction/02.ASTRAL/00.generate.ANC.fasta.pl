

my $angsd="/home/share/users/wangkun2010/software/ngsTools/angsd/angsd";

open (F,"00.realign.bam.C.list.new");
while (<F>) {
    chomp;
    my $bam=$_;
    $bam =~ /\/([^\/]+)\.\w+\.bam$/ or die "$bam\n";
    my $id=$1;

    print "$angsd -i $bam -only_proper_pairs 1 -uniqueOnly 1 -remove_bads 1 -nThreads 30 -minQ 20 -minMapQ 30 -doFasta 2 -basesPerLine 100 -doCounts 1 -out consensus_fa/$id\n";
}

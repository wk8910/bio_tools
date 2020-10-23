#! /usr/bin/env perl
use strict;
use warnings;

my $dir="fasta";
my $outdir="$dir.blast_file";
`mkdir $outdir` if(!-e $outdir);
my @pep=<$dir/*.pep>;

open O,"> $0.sh";
for(my $i=0;$i<@pep;$i++){
    my $db=$pep[$i];
    $db=~/\/([^\/]+)$/;
    my $db_name=$1;
    # print O "~/software/diamond/diamond makedb --in $db -d $db --threads 96\n";
    print O "~/software/blast/ncbi-blast-2.9.0+/bin/makeblastdb -in $db -out $db -dbtype prot\n";
    for(my $j=0;$j<@pep;$j++){
        next if($i==$j);
        my $query=$pep[$j];
        $query=~/\/([^\/]+)$/;
        my $query_name=$1;
        my $out="$outdir/$db_name.$query_name.blast";
        $out=~s/\.pep//g;
        # print O "~/software/diamond/diamond blastp -d $db -q $query -o $out --threads 96\n";
        print O "~/software/blast/ncbi-blast-2.9.0+/bin/blastp -query $query -db $db -out $out -outfmt 6 -num_threads 128\n";
    }
}
close O;

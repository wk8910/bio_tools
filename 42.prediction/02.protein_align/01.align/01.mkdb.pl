#! /usr/bin/env perl
use strict;
use warnings;

my $now=$ENV{'PWD'};
my @lib=</data2/home/wangkun/03.sterlet/00.genome/sterlet.fa>;
my $query="/data2/home/wangkun/03.sterlet/02.protein_align/00.protein/spottedGar.pep";
my $outdir="alignment";
`mkdir $outdir` if(!-e $outdir);

# ~/software/blat/blat /public/home/wangkun/projects/lungfish/06.bionano_scaffold/lungfish_pilon_bionano.fasta ../../proteins/human/human.pep -makeOoc=/public/home/wangkun/projects/lungfish/06.bionano_scaffold/lungfish_pilon_bionano.fasta.ooc -t=dnax -q=prot out.psl

open O,"> $0.sh";
foreach my $lib(@lib){
    $lib=~/^(.*)\/([^\/]+).fa$/;
    my $id=$2;    my $prefix=$1;    `mkdir $outdir/$id` if(!-e "$outdir/$id");
    # print O "cd $now/$outdir/$id; ln -s $prefix/$id.* .; ~/software/spaln/spaln/bin/spaln -Q7 -O0 -t32 -d $id $query > $id.gff ; cd -\n";
    print O "cd $now/$outdir/$id; ~/software/blat/blat $lib $query -makeOoc=$lib.ooc -t=dnax -q=prot out.psl ;  cd -\n";
}
close O;
